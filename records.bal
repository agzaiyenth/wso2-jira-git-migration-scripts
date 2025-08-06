public type JiraProject record {
    string key;
    string name;
};

public type JiraTicketResponse record {
    json[] issues;
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