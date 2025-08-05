import ballerina/http;
import ballerina/io;

http:Client jiraClient = check new (
    jiraApiBaseUrl, {
        auth: {
            username: username,
            password: password
        }
    }
);

public function main() returns error? {
    JiraProject[] projects = check getAllProjects(jiraClient);
    io:print(projects.length());
    foreach JiraProject project in projects {
        io:println(string `Processing project ${project.key} (${project.name})`);
        JiraTicket[] tickets = check getAllTicketsForProject(jiraClient, project.key);
        foreach JiraTicket ticket in tickets {
            io:println(string `Processing ticket ${ticket.key}`);
            var _ = check processIssue(ticket);
        }
    }
}
