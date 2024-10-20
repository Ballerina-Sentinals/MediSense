import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;


public type Post record {|
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

public type Comment record {|
    @sql:Column {name: "comment_id"}
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

public type PostCreated record {|
    *http:Created;
    Post body;
    |};

public type CommentCreated record {|
    *http:Created;
     Comment body;
    |};

public type NewComment record {|
    int postId;
    int userId;
    string description;
    |};

public type PostWithMeta record {|
    int id;
    int userId;
    string description;
    Meta meta;
|};

public type Meta record {|
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

public function get_posts(string? category,mysql:Client dbClient) returns Post[]|error {
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

    public function delete_post(int id, mysql:Client dbClient) returns http:NoContent|error {
        _ = check dbClient->execute(`DELETE FROM POSTS WHERE ID = ${id}`);
        return http:NO_CONTENT;
    }

    public function add_comment(NewComment newComment, mysql:Client dbClient) returns CommentCreated|http:BadRequest|error {
        //Check wether the post exists in the posts table
        Post|error post = dbClient->queryRow(`SELECT * FROM POSTS WHERE ID = ${newComment.postId}`);
        if (post is error) {
            return http:BAD_REQUEST;
        }
        sql:ExecutionResult result = check dbClient->execute(`INSERT INTO COMMENTS (POST_ID, USER_ID, CONTENT) VALUES (${newComment.postId}, ${newComment.userId}, ${newComment.description})`);
        string|int? id = result.lastInsertId;
        return id is int ? <CommentCreated>{body: {id: id, postId: newComment.postId, userId: newComment.userId, description: newComment.description}} : error("Error occurred while retriving the comment id");
    }

    public function get_comments(int postId, mysql:Client dbClient) returns Comment[]|error {
        stream<Comment, sql:Error?> commentStream = dbClient->query(`SELECT * FROM COMMENTS WHERE POST_ID = ${postId}`);
        return from Comment comment in commentStream
            select comment;
    }

    public function get_post_with_comments(int id, mysql:Client dbClient) returns PostWithComments|http:NotFound|error {
        Post|error post = dbClient->queryRow(`SELECT * FROM POSTS WHERE ID = ${id}`);
        if (post is error) {
            return http:NOT_FOUND;
        }
        stream<Comment, sql:Error?> commentStream = dbClient->query(`SELECT * FROM COMMENTS WHERE POST_ID = ${id}`);
        Comment[]|error comments = from Comment comment in commentStream 
        select comment;
        return <PostWithComments>{post: post, comments: check comments};
    }

    public function delete_comment(int id, mysql:Client dbClient) returns http:NoContent|error {
        _ = check dbClient->execute(`DELETE FROM COMMENTS WHERE COMMENT_ID = ${id}`);
        return http:NO_CONTENT;
    }

    public function get_post_with_meta(int id, mysql:Client dbClient) returns PostWithMeta|http:NotFound|error {
        Post|error post = dbClient->queryRow(`SELECT * FROM POSTS WHERE ID = ${id}`);
        if (post is error) {
            return http:NOT_FOUND;
        }
        return transformPost(post);
    }

    // public function filter_by_tags(string[] tags, mysql:Client dbClient) returns Post[]|error {
        


        