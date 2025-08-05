#!/bin/zsh

rm -rf mock_jira_store

mkdir mock_jira_store
cd mock_jira_store

# Create a mock folder structure
mkdir -p attachmentFile/APIMINTERNAL/APIMINTERNAL-401
mkdir -p attachmentFile/APIMINTERNAL/APIMINTERNAL-2148
mkdir -p attachmentFile/IAMINTERNAL/ticket1
mkdir -p attachmentFile/IAMINTERNAL/ticket2

# Create some mock files
touch attachmentFile/APIMINTERNAL/APIMINTERNAL-401/file1-1.txt
touch attachmentFile/APIMINTERNAL/APIMINTERNAL-2148/Coelsa.json
touch attachmentFile/IAMINTERNAL/ticket1/file3.txt
touch attachmentFile/IAMINTERNAL/ticket2/file4.txt
touch attachmentFile/IAMINTERNAL/ticket2/file5.txt

cd ../../
