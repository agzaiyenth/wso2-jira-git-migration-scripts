import ballerina/http;

configurable string gitHubApiBaseUrl = "https://api.github.com/";
configurable string accessToken = ?;

http:Client githubClient = check new (
    gitHubApiBaseUrl, {
        auth: {
            token: accessToken
        }
    }
);

function getIssues(string owner, string repo, int page = 1, int per_page = 30) returns json|error {
    string path = string `repos/${owner}/${repo}/issues?page=${page}&per_page=${per_page}`;
    http:Response response = check githubClient->get(path);
    json jsonResponse = check response.getJsonPayload();
    return jsonResponse;
}

function getIssueDetails(string owner, string repo, int issueId) returns json|error {
    string path = string `repos/${owner}/${repo}/issues/${issueId}`;
    http:Response response = check githubClient->get(path);
    json jsonResponse = check response.getJsonPayload();
    return jsonResponse;
}

function closeIssue(string owner, string repo, int issueId) returns json|error {
    string path = string `repos/${owner}/${repo}/issues/${issueId}`;
    json payload = { "state": "closed" };
    http:Response response = check githubClient->patch(path, payload);
    json jsonResponse = check response.getJsonPayload();
    return jsonResponse;
}


function createIssue(string owner, string repo, json payload) returns json|error {
    string path = string `repos/${owner}/${repo}/issues`;
    http:Response response = check githubClient->post(path, payload);
    json jsonResponse = check response.getJsonPayload();
    return jsonResponse;
}

function updateLabels(string owner, string repo, int issueId, json payload) returns json|error {
    string path = string `repos/${owner}/${repo}/issues/${issueId}/labels`;
    http:Response response = check githubClient->put(path, payload);
    json jsonResponse = check response.getJsonPayload();
    return jsonResponse;
}

function addComment(string owner, string repo, int issueId, json payload) returns json|error {
    string path = string `repos/${owner}/${repo}/issues/${issueId}/comments`;
    http:Response response = check githubClient->post(path, payload);
    json jsonResponse = check response.getJsonPayload();
    return jsonResponse;
}
