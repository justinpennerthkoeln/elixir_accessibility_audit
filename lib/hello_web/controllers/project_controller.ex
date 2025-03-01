defmodule HelloWeb.ProjectController do
  use HelloWeb, :controller
  alias Hello.Repo
  alias Hello.Projects
  alias Hello.Users
  alias Hello.Members
  alias Hello.Issues
  import Ecto.Query

  def create_project(conn, %{"project_name" => project_name, "user_token" => user_token}) do
    try do
      changeset = Projects.changeset(%Projects{}, %{"name" => project_name})
      case Repo.insert(changeset) do
        {:ok, project} ->
          user = Users.get_user_by_uuid(user_token)
          projectId = project.id
          userId = user.id
          role = "owner"

          memberChangeset = Members.changeset(%Members{}, %{"user_id" => userId, "project_id" => projectId, "role" => role})
          case Repo.insert(memberChangeset) do
            {:ok, _member} ->
              projects = get_projects(conn, %{"uuid" => user_token})
              conn
              |> put_status(:created)
              |> json(%{success: true, projects: projects})
            {:error, _changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{success: false, message: "Something went wrong!"})
            end
        {:error, _changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{success: false, message: "Something went wrong!"})
      end
    rescue
      _e ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{success: false, message: "Something went wrong!"})
    end
  end

  def get_projects(conn, %{"uuid" => uuid}) do
    user = Users.get_user_by_uuid(uuid)
    memberships = Repo.all(from(m in Hello.Members, where: m.user_id == ^user.id, select: m))
    project_ids = Enum.map(memberships, &(&1.project_id))
    projects = Repo.all(from(p in Hello.Projects, where: p.id in ^project_ids, select: p))
    projects = Enum.map(projects, fn project ->
      members = Repo.all(from(m in Hello.Members, where: m.project_id == ^project.id, select: m))
      members = Enum.map(members, fn member ->
        user = Repo.get(Hello.Users, member.user_id)
        Map.put(member, :user, user)
      end)
      issues = Repo.all(from(i in Hello.Issues, where: i.project_id == ^project.id, select: i))
      issues = Repo.preload(issues, :user)

      project = Map.put(project, :members, members)
      project = Map.put(project, :issues, issues)
      project_json = %{
        id: project.id,
        uuid: project.uuid,
        name: project.name,
        inserted_at: project.inserted_at,
        updated_at: project.updated_at,
        members: Enum.map(members, &%{id: &1.id, uuid: &1.uuid, role: &1.role, inserted_at: &1.inserted_at, username: &1.user.username}),
        issues: Enum.map(issues, &%{id: &1.id, uuid: &1.uuid, user_id: &1.user_id, project_id: &1.project_id, status: &1.status, filename: &1.filename, matches: &1.matches, matches_count: &1.matches_count, user: &1.user, inserted_at: &1.inserted_at, updated_at: &1.updated_at})
      }
      project_json
    end)

    json(conn, projects)
  end

  def get_project(conn, %{"uuid" => uuid}) do
    project = Repo.get_by(Hello.Projects, uuid: uuid)
    members = Repo.all(from(m in Hello.Members, where: m.project_id == ^project.id, select: m))
    members = Enum.map(members, fn member ->
      user = Repo.get(Hello.Users, member.user_id)
      Map.put(member, :user, user)
    end)
    issues = Repo.all(from(i in Hello.Issues, where: i.project_id == ^project.id, select: i))

    project = Map.put(project, :members, members)

    issues = Enum.map(issues, fn issue ->
      user = Repo.get(Hello.Users, issue.user_id)
      Map.put(issue, :user, %{uuid: user.uuid, username: user.username})
    end)

    project = Map.put(project, :issues, issues)


    project_json = %{
      id: project.id,
      uuid: project.uuid,
      name: project.name,
      inserted_at: project.inserted_at,
      updated_at: project.updated_at,
      members: Enum.map(members, &%{id: &1.id, uuid: &1.uuid, role: &1.role, inserted_at: &1.inserted_at, username: &1.user.username}),
      issues: Enum.map(issues, &%{id: &1.id, uuid: &1.uuid, user_id: &1.user_id, project_id: &1.project_id, status: &1.status, filename: &1.filename, matches: &1.matches, matches_count: &1.matches_count, user: &1.user, inserted_at: &1.inserted_at, updated_at: &1.updated_at})
    }
    json(conn, project_json)
  end

  def add_member(conn, %{"uuid" => project_uuid, "user_token" => user_uuid}) do
    project = Repo.get_by(Hello.Projects, uuid: project_uuid)
    user = Repo.get_by(Hello.Users, uuid: user_uuid)
    changeset = Members.changeset(%Members{}, %{"user_id" => user.id, "project_id" => project.id})

    case Repo.insert(changeset) do
      {:ok, _member} ->
        members = Repo.all(from(m in Hello.Members, where: m.project_id == ^project.id, select: m))
        members = Enum.map(members, fn member ->
          user = Repo.get(Hello.Users, member.user_id)
          Map.put(member, :user, user)
        end)
        issues = Repo.all(from(i in Hello.Issues, where: i.project_id == ^project.id, select: i))
        issues = Repo.preload(issues, :user)

        project_json = %{
          id: project.id,
          uuid: project.uuid,
          name: project.name,
          inserted_at: project.inserted_at,
          updated_at: project.updated_at,
          members: Enum.map(members, &%{id: &1.id, uuid: &1.uuid, role: &1.role, inserted_at: &1.inserted_at, username: &1.user.username}),
          issues: Enum.map(issues, &%{id: &1.id, uuid: &1.uuid, status: &1.status, filename: &1.filename, matches: &1.matches, matches_count: &1.matches_count, user: &1.user, inserted_at: &1.inserted_at, updated_at: &1.updated_at})
        }
        conn
        |> put_status(:created)
        |> json(project_json)
      {:error, _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, message: "Something went wrong!"})
    end
  end

  def delete_member(conn, %{"uuid" => member_uuid}) do
    Repo.delete_all(from(m in Hello.Members, where: m.uuid == ^member_uuid))
    conn
    |> put_status(:ok)
    |> json(%{success: true})
  end

  def add_issue(conn, %{"uuid" => project_uuid, "user_token" => user_uuid, "audit_results" => audit_results, "filename" => filename}) do
    project = Repo.get_by(Hello.Projects, uuid: project_uuid)
    user = Repo.get_by(Hello.Users, uuid: user_uuid)
    matches = audit_results["matches"]
    |> Enum.map(fn match -> {match["dataAttributeId"], match} end)
    |> Enum.into(%{})

    issue_changeset = Issues.changeset(%Issues{}, %{
      "user_id" => user.id,
      "project_id" => project.id,
      "matches" => matches,
      "html" => "test",
      "matches_count" => audit_results["numberOfErrors"],
      "filename" => filename
    })
    case Repo.insert(issue_changeset) do
      {:ok, _issue} ->
        conn
        |> put_status(:created)
        |> json(%{success: true})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, message: "Something went wrong!"})
    end
  end

  def delete_project(conn, %{"uuid" => project_uuid}) do
    project = Repo.get_by(Hello.Projects, uuid: project_uuid)
    Repo.delete_all(from(m in Hello.Members, where: m.project_id == ^project.id))
    Repo.delete_all(from(i in Hello.Issues, where: i.project_id == ^project.id))
    Repo.delete(project)
    conn
    |> put_status(:ok)
    |> json(%{success: true})
  end

end
