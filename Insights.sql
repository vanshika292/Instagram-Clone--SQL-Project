
use ig_clone;

-- INSIGHTS


-- User Analysis:

-- Find the 5 oldest users.
select * from users
order by created_at
limit 5;

-- How many times does the average user post?
SELECT (SELECT Count(*) FROM photos) / 
		(SELECT Count(*) FROM users) AS avg; 

-- What day of the week do most users register on?
select dayname(created_at) as day, count(id) as total_users
from users
group by dayname(created_at)
order by 2 desc
limit 2;

-- Find the users who have never posted a photo.
select username from users
left join photos 
on users.id = photos.user_id
group by 1
having count(image_url) = 0;

-- Identify the top 5 most active users based on the number of photos they have posted. (Top 5 active users)
select username, count(*) as "total photos posted"
from users
join photos
on users.id = photos.user_id
group by user_id
order by count(*) desc
limit 5;

-- Determine the top 10 users who have received the most likes on their photos.
select username, count(likes.user_id) as "total likes count"from users
join photos on users.id = photos.user_id
JOIN likes ON photos.id = likes.photo_id
group by 1
order by 2 desc
limit 10;

-- Find top 3 users who have the highest number of followers.
select username, count(follower_id) from follows
join users
on users.id = follows.followee_id
group by followee_id
order by count(follower_id) desc
limit 3;

-- Calculate the average number of comments per user's photos to assess user engagement.
SELECT users.username, AVG(comment_count) AS avg_comments_per_photo
FROM users
JOIN photos ON users.id = photos.user_id
LEFT JOIN (
    SELECT photo_id, COUNT(*) AS comment_count
    FROM comments
    GROUP BY photo_id
) AS photo_comments ON photos.id = photo_comments.photo_id
GROUP BY users.id;



-- Photo Analysis:

-- Find users who have liked every single photo on the site
select user_id, username, count(photo_id) as "number of likes"
from likes
join users
on users.id = likes.user_id
group by user_id
having count(photo_id) = (select count(*) from photos);

-- Determine the 15 most liked photos and identify the users who posted them.
select users.username, photos.image_url, count(likes.user_id) as "total likes" from photos 
join likes on photos.id = likes.photo_id
join users on users.id = photos.user_id
group by likes.photo_id
order by count(likes.user_id) desc
limit 15;

-- who can get the most likes on a single photo.
SELECT 
	users.id,
    username,
    photos.id,
    photos.image_url, 
    COUNT(*) AS total
FROM photos
INNER JOIN likes
    ON likes.photo_id = photos.id
INNER JOIN users
    ON photos.user_id = users.id
GROUP BY photos.id
ORDER BY total DESC
LIMIT 1;

-- Find 5 photos with the highest number of comments.
select photos.id, photos.image_url, count(comments.id) as "total comments" from photos 
join comments on photos.id = comments.photo_id
group by comments.photo_id
order by count(comments.id) desc
limit 5;

-- Analyze the distribution of tags across photos to identify popular themes or topics.
select tag_id, tag_name, count(photo_id) from tags
left join photo_tags
on tags.id = photo_tags.tag_id
group by tags.id
order by count(photo_id) desc;

-- Calculate the average number of likes and comments per photo to understand photo engagement.
SELECT AVG(like_count) AS avg_likes_per_photo, AVG(comment_count) AS avg_comments_per_photo
FROM (
    SELECT photo_id, COUNT(DISTINCT user_id) AS like_count
    FROM likes
    GROUP BY photo_id
) AS like_counts
JOIN (
    SELECT photo_id, COUNT(*) AS comment_count
    FROM comments
    GROUP BY photo_id
) AS comment_counts ON like_counts.photo_id = comment_counts.photo_id;




-- User Interactions:

-- Identify the users who follow each other reciprocally (mutual followers).
SELECT DISTINCT users.username AS mutual_follower
FROM follows AS A
JOIN follows AS B 
ON A.follower_id = B.followee_id 
AND A.followee_id = B.follower_id
JOIN users 
ON A.follower_id = users.id
WHERE A.follower_id < A.followee_id;

-- Find 10 users who have received the most comments on their photos.
select users.username, count(comments.id) as "total comments" from photos 
join users
on users.id = photos.user_id
join comments
on photos.id = comments.photo_id
group by photos.user_id
order by count(comments.id) desc
limit 10;




-- Hashtag Analysis:

-- Identify the 10 most popular hashtags based on their frequency in the posts.
select tag_id, tag_name, count(photo_id) from tags
left join photo_tags
on tags.id = photo_tags.tag_id
group by tags.id
order by count(photo_id) desc
limit 10;

-- Find photos with specific hashtags to analyze their content.
select tag_name, image_url from photo_tags
join photos
on photo_tags.photo_id = photos.id
join tags
on photo_tags.tag_id = tags.id
where tag_name in ("smile","delicious");

-- Determine the users who frequently use specific hashtags.
SELECT users.username, COUNT(photo_tags.tag_id) AS hashtag_count
FROM users
JOIN photos ON users.id = photos.user_id
JOIN photo_tags ON photos.id = photo_tags.photo_id
JOIN tags ON photo_tags.tag_id = tags.id
WHERE tags.tag_name IN ('smile', 'delicious')
GROUP BY users.id
ORDER BY hashtag_count DESC;
