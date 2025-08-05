import ballerina/file;
import ballerina/io;

function _getFilePathsTest() returns error? {
    string[] filePaths = check getAttachmentIDs("mock_jira_store/attachmentFile", "project1", "ticket1");
    io:println("File paths: ", filePaths);
}

function getAttachmentIDs(string basePath, string projectId, string ticketId) returns string[]|error {
    string ticketFolderPath = basePath + "/" + projectId + "/" + ticketId;

    string[] files = [];
    int index = 0;
    
    if (check file:test(ticketFolderPath, file:EXISTS)) {
        var result = file:readDir(ticketFolderPath);
        
        if (result is file:MetaData[]) {
            foreach file:MetaData item in result {
                if (item.dir) {
                    continue;
                }
                string fileName = getFileName(item.absPath);
                // files[index] = ticketFolderPath + "/" + fileName;  // Attach the file path
                files[index] = fileName;  // Attach the file name
                index += 1;
            }
        } else {
            return error("Error reading directory: ", result);
        }
    } else {
        return error("Ticket folder does not exist.");
    }
    
    return files;
}

function getFileName(string absPath) returns string {
    string[] pathComponents = splitString(absPath, "/");
    return pathComponents[pathComponents.length() - 1];
}
