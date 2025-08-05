public type JiraProject record {
    string key;
    string name;
};

public type JiraTicketResponse record {
    json[] issues;
};

public type JiraTicket record {
    string key;
    string summary;
    string description;
    string reporterName;
    string reporterEmail;
    string createdDate;
    string[] labels;
    Attachment[] attachments;
    Comment[] comments;
};

public type Attachment record {
    string id;
    string filename;
    string mimeType;
    string content;
    Author author;
};

public type AttachmentResponse record {
    AttachmentResponseFields fields?;
};

public type AttachmentResponseFields record {
    Attachment[] attachment?;
};

public type CommentResponse record {
    Comment[] comments;
};

public type Comment record {
    string body;
    Author author;
    string created;
};

public type Author record {
    string displayName;
    string emailAddress;
};