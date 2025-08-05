# Splits a string into an array of substrings based on a specified delimiter.
#
# ```ballerina
# string inputString = "Ballerina is a great programming language";
# string delimiter = " ";
# string[] result = splitString(inputString, delimiter);
# // result: ["Ballerina", "is", "a", "great", "programming", "language"]
# ```
#
# + inputString - the string to be split
# + delimiter - the string to use as the delimiter for splitting
# + return - an array of substrings that were separated by the delimiter
function splitString(string inputString, string delimiter) returns string[] {
    string[] result = [];
    int startIndex = 0;

    // Iterate through the input string and search for the delimiter
    while (true) {
        int? delimiterIndex = inputString.indexOf(delimiter, startIndex);
        
        // If the delimiter is found, extract the substring and update the startIndex
        if (delimiterIndex is int) {
            string chunk = inputString.substring(startIndex, delimiterIndex);
            result.push(chunk);
            startIndex = delimiterIndex + delimiter.length();
        } else {
            // If the delimiter is not found, exit the loop
            break;
        }
    }

    // Add the remaining part of the string to the result array
    if (startIndex < inputString.length()) {
        result.push(inputString.substring(startIndex));
    }

    return result;
}
