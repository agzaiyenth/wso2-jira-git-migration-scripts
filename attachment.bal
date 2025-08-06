import ballerina/http;
import ballerina/io;

// Download attachment from Jira
function downloadAttachment(http:Client jiraClient, string attachmentUrl) returns byte[]|error {
    http:Response response = check jiraClient->get(attachmentUrl);
    
    if (response.statusCode != 200) {
        return error(string `Failed to download attachment. Status: ${response.statusCode}`);
    }
    
    byte[] fileBytes = check response.getBinaryPayload();
    return fileBytes;
}

// Upload attachment to GitHub repository
function uploadAttachmentToGitHub(byte[] fileBytes, string fileName, string issueKey, string owner, string repo) returns string|error {
    string filePath = string `jira-attachments/${issueKey}/${fileName}`;
    
    // Encode file content to base64
    string base64Content = fileBytes.toBase64();
    
    json payload = {
        "message": string `Add Jira attachment: ${fileName} for issue ${issueKey}`,
        "content": base64Content,
        "branch": "main"
    };
    
    string path = string `repos/${owner}/${repo}/contents/${filePath}`;
    http:Response response = check githubClient->put(path, payload);
    
    if (response.statusCode != 201) {
        json errorResponse = check response.getJsonPayload();
        return error(string `Failed to upload attachment to GitHub: ${errorResponse.toJsonString()}`);
    }
    
    json responseJson = check response.getJsonPayload();
    string downloadUrl = (check responseJson.content.download_url).toString();
    return downloadUrl;
}

// Add comment to GitHub issue with attachment link
function addAttachmentCommentToGitHubIssue(string owner, string repo, int issueNumber, string downloadUrl, string fileName) returns json|error {
    string commentBody = string `📎 **Jira Attachment**: [${fileName}](${downloadUrl})`;
    
    json payload = {
        "body": commentBody
    };
    
    return check addComment(owner, repo, issueNumber, payload);
}

// Process all attachments for a single issue
function processIssueAttachments(http:Client jiraClient, JiraTicket ticket, string owner, string repo, int githubIssueNumber) returns error? {
    if (ticket.attachments.length() == 0) {
        io:println(string `No attachments found for issue ${ticket.key}`);
        return;
    }
    
    io:println(string `Processing ${ticket.attachments.length()} attachments for issue ${ticket.key}`);
    
    foreach Attachment attachment in ticket.attachments {
        do {
            io:println(string `Downloading attachment: ${attachment.filename}`);
            
            // Download from Jira
            byte[] fileBytes = check downloadAttachment(jiraClient, attachment.content);
            
            // Upload to GitHub
            string downloadUrl = check uploadAttachmentToGitHub(
                fileBytes, 
                attachment.filename, 
                ticket.key, 
                owner, 
                repo
            );
            
            // Add comment with attachment link
            _ = check addAttachmentCommentToGitHubIssue(
                owner, 
                repo, 
                githubIssueNumber, 
                downloadUrl, 
                attachment.filename
            );
            
            io:println(string `Successfully migrated attachment: ${attachment.filename}`);
            
        } on fail var e {
            io:println(string `Failed to migrate attachment ${attachment.filename}: ${e.message()}`);
            // Continue with other attachments even if one fails
        }
    }
}