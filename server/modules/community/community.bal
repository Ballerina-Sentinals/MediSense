import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;


type Post record {|
    @sql:Column {name: "id"}
    readonly int id;
    @sql:Column {name: "user_id"}
    int userId;
    @sql:Column {name: "description"}
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

public type NewPost record {|
    int user_Id;
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

# Transforms a Post record to a PostWithMeta record.
#
# + post - The Post record to be transformed
# + return - The transformed PostWithMeta record
function transformPost(Post post) returns PostWithMeta => {
    id: post.id,
    userId: post.userId,
    description: post.description,
    meta: {
        category: post.category,
        tags: re `,`.split(post.tags)
    }
};

public function get_post(string? category,mysql:Client dbClient) returns Post[]|error {
        sql:ParameterizedQuery query = category is string ?
            `SELECT * FROM POSTS WHERE CATEGORY = ${category}` : `SELECT * FROM POSTS`;
        stream<Post, sql:Error?> postStream = dbClient->query(query);
        return from Post post in postStream
            select post;
    }

    public function  get_post_byindex(int id,mysql:Client dbClient) returns Post|http:NotFound//return post or an error 
    {
        Post|error post = dbClient->queryRow(`SELECT * FROM POSTS WHERE ID = ${id}`);
        return post is Post ? post : http:NOT_FOUND;
    }

    public function create_post(NewPost newPost, mysql:Client dbClient) returns PostCreated|http:BadRequest|error {

        sql:ExecutionResult result = check dbClient->execute(`INSERT INTO POSTS (USER_ID, DESCRIPTION, TAGS, CATEGORY) VALUES (${newPost.user_Id}, ${newPost.description}, ${newPost.tags}, ${newPost.category})`);
        string|int? id = result.lastInsertId;
        return id is int ? <PostCreated>{body: {id: id, userId: newPost.user_Id, description: newPost.description, tags: newPost.tags, category: newPost.category}} : error("Error occurred while retriving the post id");
    }

    public function delete_posts(int id, mysql:Client dbClient) returns http:NoContent|error {
        _ = check dbClient->execute(`DELETE FROM POSTS WHERE ID = ${id}`);
        return http:NO_CONTENT;
    }