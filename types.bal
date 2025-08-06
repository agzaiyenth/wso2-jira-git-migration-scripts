public type Attachment record {
    string id;
    string filename;
    string content; // URL to download the attachment
    int size?;
    string mimeType?;
};

public type JiraTicket record {
    string key;
    string summary;
    string description;
    string[] labels;
    Comment[] comments;
    string reporterName;
    string reporterEmail;
    string createdDate;
    Attachment[] attachments;
};

// Other existing types...