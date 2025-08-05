// import ballerina/io;
// import ballerina/file;
// import ballerina/http;
// import ballerina/jsonutils;
// import ballerina/log;
// import ballerina/url;
// import ballerina/io;
// import ballerina/mime;

// // Method to process and upload attachments from JIRA to ServiceNow
// public function getAttachments(string ID, string caseSysId) {
//     // Log the start of attachment processing
//     log:printInfo("Processing attachments for id: " + ID + " ,Case Id: " + caseSysId);

//     // Create a new UploadFile object
//     UploadFile uploadFile = new UploadFile();

//     // Extract the project key from the ID
//     string projectKey = ID.substring(0, ID.indexOf("-"));

//     // Send a GET request to fetch attachment details from JIRA
//     string response = check sendGetRequest(jiraUrl + ID + "?fields=attachment");

//     // Parse the response JSON
//     json jsonResponse = check jsonutils:fromString(response);
//     json fields = jsonResponse.fields;
//     json[] arrachmentArray = fields.attachment;

//     // Check if there are any attachments
//     if arrachmentArray.length() > 0 {
//         // Iterate through all attachments
//         foreach var k in 0..<arrachmentArray.length() {
//             // Get attachment details
//             json id = arrachmentArray[k];
//             string attachemntId = id.id.toString();
//             string created = id.created.toString();
//             json author = id.author;

//             // Check if attachment already exists in the target system
//             if !isAttachmentExists(attachemntId) {
//                 // Get author email address or set a default one
//                 string authorEmailAddress = "";
//                 if author != null {
//                     authorEmailAddress = emailConversion(author.emailAddress.toString());
//                 } else {
//                     authorEmailAddress = "wso2pmtuser@wso2.com";
//                 }

//                 // Get attachment details like content type and file name
//                 string contentType = id.mimeType.toString();
//                 string fileName = id.filename.toString();

//                 // Find the local path of the attachment file
//                 string|error localPath = findFiles(projectKey, id.id.toString());

//                 string attachmentResponse = "";
//                 // Check if the local path is valid
//                 if localPath is string {
//                     if (localPath == "-") {
//                         // If the local path is not valid, try finding the file with a different name
//                         string filenameWithId = id.id.toString() + "_" + fileName;
//                         localPath = check findFiles(projectKey, filenameWithId);

//                         // Attach the file to the target system
//                         attachmentResponse = check uploadFile.attachFiles(caseSysId, localPath);
//                     } else {
//                         // Attach the binary file to the target system
//                         attachmentResponse = check uploadFile.attachBinaryFile(contentType, localPath, fileName, caseSysId);
//                     }
                    
//                     // Parse the attachment response
//                     json attachmentResponseJson = check jsonutils:fromString(attachmentResponse);
//                     json attachmentOutputArray = attachmentResponseJson.result;

//                     // Update the created by and created on fields for the attachment
//                     updateCreateByAndCreatedOn(
//                         attachmentOutputArray.sys_id.toString(), 
//                         authorEmailAddress, 
//                         created, 
//                         created, 
//                         "sys_attachment"
//                     );
//                     log:printInfo("Sys Id: " + attachmentOutputArray.sys_id.toString());

//                     // Insert the attachment details into the database
//                     insertAttachments(
//                         ID, 
//                         attachemntId, 
//                         caseSysId, 
//                         attachmentOutputArray.sys_id.toString(), 
//                         url:encode(attachmentOutputArray.file_name.toString(), "UTF-8"), 
//                         attachmentOutputArray.content_type.toString(), 
//                         attachmentOutputArray.state.toString()
//                     );
//                 }
//             }
//         }
//     } else {
//         // If no attachments found, insert a record with
//         // an empty attachment
//         if !isEmptyAttachemntExists(ID) {
//             insertAttachments(ID, "-", caseSysId, "-", "-", "-", "-");
//         }
//     }
//     // Log the completion of attachment processing
//     log:printInfo("Processing attachments completed for id: " + ID + " ,Case Id: " + caseSysId);
// }

// // Method to find the attachment file path
// public function findFiles(string projectKey, string fileName) returns string|error {
//     // Build the path using the project key
//     string stringPath = attachmentFile + projectKey;
//     string[]|error result = findByFileName(stringPath, fileName);
//     string files = "";

//     // Combine the file paths found
//     if (result is string[]) {
//         foreach int i in 0 ..< result.length() {
//             if (i > 0) {
//                 files += "   " + result[i];
//             } else {
//                 files = result[i];
//             }
//         }
//     } else {
//         return error("Error finding files");
//     }

//     // Return the file path or a placeholder if not found
//     if (files == "") {
//         files = "-";
//     }
//     return files;
// }

// // Method to find files with a specific file name within a directory and its subdirectories
// public function findByFileName(string path, string fileName) returns string[]|error {
//     string[] fileResult = [];
//     // Search for files with the given file name within the directory and its subdirectories
//     var result = check file:search(path, function(file:FileInfo info) returns boolean {
//         return info.name.equalsIgnoreCase(fileName);
//     });

//     // Filter out directories and add only files to the fileResult list
//     foreach var file in result {
//         if (file.isDir()) {
//             continue;
//         }
//         fileResult.push(file.absPath);
//     }
//     return fileResult;
// }
