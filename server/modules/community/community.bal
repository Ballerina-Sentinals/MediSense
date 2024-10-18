import ballerina/http;
import ballerina/sql;
import ballerina/io;

# Returns the string `Hello` with the input string name.
#
# + name - name as a string or nil
# + return - "Hello, " with the input string name

type Post record {|
    @sql:Column {name: "id"}
    readonly int id;
    @sql:Column {name: "user_id"}
    int userId;
    @sql:Column {name: "content"}
    string description;
    @sql:Column {name: "tags"}
    string tags;
    @sql:Column {name: "category"}
    string category;
|};

type Comment record {|
    @sql:Column {name: "id"}
    readonly int id;
    @sql:Column {name: "post_id"}
    int postId;
    @sql:Column {name: "user_id"}
    int userId;
    @sql:Column {name: "content"}
    string description;
    |};

type NewPost record {|
    int userId;
    string description;
    string tags;
    string category;
|};

type PostCreated record {|
    *http:Created;
    Post body;
    |};

type CommentCreated record {|
    *http:Created;
     Comment body;
    |};

type NewComment record {|
    int postId;
    int userId;
    string description;
    |};

type PostWithMeta record {|
    int id;
    int userId;
    string description;
    Meta meta;
|};

type Meta record {|
    string[] tags;
    string category;
|};

type PostWithComments record {|
    Post post;
    Comment[] comments;
|};

function transformPost(Post post) returns PostWithMeta => {
    id: post.id,
    userId: post.userId,
    description: post.description,
    meta: {
        category: post.category,
        tags: re `,`.split(post.tags)
    }
};
