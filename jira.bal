import ballerina/http;
import ballerina/io;

public function processIssue(JiraTicket ticket) returns error? {
    string ticketBody = string `**Reporter:** ${ticket.reporterName} (${ticket.reporterEmail})<br />**Created On:** ${ticket.createdDate}<br /><br />${ticket.description}<br /><br />**Attachments:** ${ticket.attachments.length()} file(s)`;

    json response = check createIssue(
        "agzaiyenth",
        "agzaiyenth",
        {
            "title": ticket.key + " - " + ticket.summary, 
            "body": ticketBody
        }
    );
    
    io:println(string `RESPONSE: ${response.toJsonString()}`);
    int issueNumber = check response.number;
    
    // Process comments
    foreach Comment comment in ticket.comments {
        string commentBody = string `**On ${comment.created} ${comment.author.displayName} (${comment.author.emailAddress}) Commented:**<br />${comment.body}`;
        response = check addComment(
            "agzaiyenth",
            "agzaiyenth",
            issueNumber,
            {
                "body": commentBody
            }
        );
    }

    // Process attachments
    _ = check processIssueAttachments(jiraClient, ticket, "agzaiyenth", "agzaiyenth", issueNumber);

    // Update labels
    response = check updateLabels(
        "agzaiyenth",
        "agzaiyenth",
        issueNumber,
        {
            "labels": ticket.labels
        }
    );
    
    // Close the issue
    _ = check closeIssue("agzaiyenth", "agzaiyenth", issueNumber);
}

function getAllProjects(http:Client jiraClient) returns JiraProject[]|error {
    // JiraProject[] projects = check jiraClient->get("/project");

    // return projects;

    // TEST CODE - Select a known project for testing.
    JiraProject testProject = {
        key: "APIMINTERNAL",
        name: "APIM Internal"
    };
    return [testProject];
}

function getAllProjectsNew(http:Client jiraClient) returns JiraProject[]|error {
    // int startAt = 0;
    // int maxResults = 50;
    // boolean isLastPage = false;
    // JiraProject[] projects = [];

    // while (!isLastPage) {
    //     string query = "/rest/api/3/project/search?startAt=" + startAt.toString() + "&maxResults=" + maxResults.toString();
    //     json response = check jiraClient->get(query);
    //     json[] projectArray = check response.values.ensureType();

    //     isLastPage = projectArray.length() < maxResults;
    //     startAt += maxResults;

    //     foreach json project in projectArray {
    //         string key = (check project.key).toString();
    //         string name = (check project.name).toString();
    //         projects.push({
    //             key: key,
    //             name: name
    //         });
    //     }
    // }

    // return projects;

    // TEST CODE - Select a known project for testing.
    JiraProject testProject = {
        key: "APIMINTERNAL",
        name: "APIM Internal"
    };
    return [testProject];
}


function getAllTicketsForProject(http:Client jiraClient, string projectKey) returns JiraTicket[]|error {
    int startAt = 0;
    int maxResults = 50;
    boolean isLastPage = false;
    string jql = string `project=${projectKey}`;
    JiraTicket[] tickets = [];

    // TEST CODE
    // startAt = 1720;
    // maxResults = 10;

    while !isLastPage {

        string query = "/search?jql=" + jql + "&startAt=" + startAt.toString() + "&maxResults=" + maxResults.toString();
        io:print(string `Query: ${query}\n`);
        io:print("jql"+jql + "\n");
        JiraTicketResponse response = check jiraClient->get(query);

        json[] issues = response.issues;
        isLastPage = issues.length() < maxResults;
        startAt += maxResults;

        foreach json issue in issues {
            string key = (check issue.key).toString();

            io:println(key);

            // TEST CODE - Select known ticket(s) for testing.
            if (key != "APIMINTERNAL-2148") {
                continue;
            }

            json fields = check issue.fields;
            string summary = (check fields.summary).toString();
            string description = (check fields.description).toString();
            string reporterName = (check fields.reporter.displayName).toString();
            string reporterEmail = (check fields.reporter.emailAddress).toString();
            string createdDate = (check fields.created).toString();
            json[] labelsJson = check fields.labels.ensureType();
            string[] labels = [];
            foreach json label in labelsJson {
                labels.push(label.toString());
            }
            Comment[] comments = check getCommentsForTicket(jiraClient, key);

            Attachment[] attachments= check getAttachmentsForTicketByFileSystem(jiraClient, projectKey, key);

            tickets.push({
                key: key,
                summary: summary,
                description: description,
                labels: labels,
                comments: comments,
                reporterName: reporterName,
                reporterEmail: reporterEmail,
                createdDate: createdDate,
                attachments: attachments
            });

            // TEST CODE - Select known ticket(s) for testing.
            if (key == "APIMINTERNAL-2148") {
                break;
            }
        }

        // TEST CODE
        break;
    }

    return tickets;
}

function getCommentsForTicket(http:Client jiraClient, string ticketKey) returns Comment[]|error {
    // CommentResponse response = check jiraClient->get(string `/issue/${ticketKey}/comment`);
    // Comment[] comments = [];
    // foreach Comment comment in response.comments {
    //     comments.push({
    //         body: comment.body,
    //         author: comment.author,
    //         created: comment.created
    //     });
    // }
    // return comments;

    // TEST CODE
    return [];
}

function getAttachmentsForTicketbyApi(http:Client jiraClient, string ticketKey) returns Attachment[]|error {
    AttachmentResponse response = check jiraClient->get(string `/issue/${ticketKey}?fields=attachment`);

    if (response?.fields != () && response?.fields?.attachment != []) {
        AttachmentResponseFields fields = check response.fields.ensureType();
        Attachment[] attachments = check fields.attachment.ensureType();
        return attachments;
    } else {
        return [];
    }
}

function getAttachmentsForTicketByFileSystem(http:Client jiraClient, string projectId, string issueId) returns Attachment[]|error {
    string[] attachmentIDs = check getAttachmentIDs("mock_jira_store/attachmentFile", projectId, issueId);
    Attachment[] attachments = [];
    foreach string attachmentId in attachmentIDs {
        // Note: You'll need to modify this to work with your file system structure
        // This assumes you have attachment metadata stored locally
        Attachment attachment = {
            id: attachmentId,
            filename: attachmentId, // You may need to get actual filename from filesystem
            content: string `${jiraApiBaseUrl}/secure/attachment/${attachmentId}/${attachmentId}`,
            size: 0, // You may want to get actual file size
            mimeType: "application/octet-stream" // You may want to detect actual MIME type
        };
        attachments.push(attachment);
    }
    return attachments;
}
            