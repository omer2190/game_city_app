# Gaming City - API Endpoints Documentation

**Base URL:** `https://gaming-city-seven.vercel.app`

## 🔐 Authentication & Users

### log in

- **POST** `/api/users/login`
  - Body: `{ email, password }`
  - Response: `{ token, user }`

### Create a new account

- **POST** `/api/users/register`
  - Body: `{ userName, email, password, firstName, lastName }`
  - Response: `{ token, user }`

### Get all users

- **GET** `/api/users`
  - Headers: `Authorization: Bearer {token}`
  - Response: `[
    "success": true,
    "count": 10,
    "data": [
      {
        "userProfile": {
             "bgProfile": []
             "bio": ******;
             "prymaryColor": #****;
        },
        "points": 0,
        "_id": "69************06",
        "userName": "******",
        "email": "**********@gmail.com",
        "role": [
            "user",
            "admin",
            "fdrfss"
        ],
        "gender": "other",
        "userImage": [
            "https://............jpg"
        ],
        "createdAt": "2025-11-22T16:30:13.627Z",
        "updatedAt": "2025-11-26T11:59:38.463Z",
        "__v": 0,
        "firstName": "******",
        "lastName": "****"
    },
    ]]`

### Get user by ID

- **GET** `/api/users/:id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ user }`

### Update user data {-role}

- **PUT** `/api/users/:id`

  - Headers: `Authorization: Bearer {token}`
  - Body: `{ updates }`
  - Response: `{ user }`

  ### Update user role {Only the owner can do this from the dashboard}

- **PUT** `/api/users/role/:id`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ updates }`
  - Response: `{ user }`

### Delete user

- **DELETE** `/api/users/:id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ success }`

---

## 📰 News

### Get all news

- **GET** `/api/news/?page=1`
  - Query: `page` (optional)
  - Response: `{ news, total, page }`

### Get news by id

- **GET** `/api/news/:id`
  - Response: `{ news }`

### Create a new news item

- **POST** `/api/news/`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ title, contentNew, images, newsType }`
  - Response: `{ news }`
    limit the number of images to 10

### Update news

- **PUT** `/api/news/:id`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ updates }`
  - Response: `{ news }`

### Delete news

- **DELETE** `/api/news/:id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ success }`

### Serch the news

- **GET** `/api/news/search?q={query}`
  - Query: `q` (required)
  - Response: `{ news }`

### Get news bu category

- **GET** `/api/news/type/:newsType`
  - Response: `{ news }`

---

## ❤️ Likes

### add/removal

- **POST** `/api/likes/togglelike`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ newsId }`
  - Response: `{ liked, count }`

### Get the number of likes

- **GET** `/api/likes/count?newsId={id}`
  - Query: `newsId` (required)
  - Response: `{ count }`

### Getting user likes

- **GET** `/api/likes/mylikes/`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ likes }`

### Get likes on the news

- **GET** `/api/likes/check/:newsId`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ likes }`

---

## 💬 Comments

### add new comment

- **POST** `/api/comments/`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ newsId, content }`
  - Response: `{ comment }`

### Get news comments

- **GET** `/api/comments/news/:newsId`
  - Response: `{ comments }`

### Update comments

- **PUT** `/api/comments/:Id`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ content }`
  - Response: `{ comment }`

### Delete comments

- **DELETE** `/api/comments/:Id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ success }`

---

## 📢 Advertisements

### Get active ads

- **GET** `/api/advertised/active`
  - Response: `{ ads }`

### Get all ads {avtive & inactive} dashboard

- **GET** `/api/advertised/`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ ads }`

### Craete new ads

- **POST** `/api/advertised`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ imageUrl, startDate, endDate, newsId? }`
  - Response: `{ ad }`

### Update ads

- **PUT** `/api/advertised/:id`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ updates }`
  - Response: `{ ad }`

### Delete ads

- **DELETE** `/api/advertised/:id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ success }`

---

## 🎮 Gaming Platforms

### Get all plat form

- **GET** `/api/gamingPlatform/`
  - Response: `{ platforms }`

### Create new plat form

- **POST** `/api/gamingPlatform`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ name }`
  - Response: `{ platform }`

### Delete plat form

- **DELETE** `/api/gamingPlatform/:id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ success }`

---

## 🎯 Coming Soon Games

### Get all coming soon games

- **GET** `/api/comingSoon/`
  - Response: `{ games }`

### Create coming soon games

- **POST** `/api/comingSoon`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ title, releaseDate, platform, imageUrl }`
  - Response: `{ game }`

### Update coming soon games

- **PUT** `/api/comingSoon/:id`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ updates }`
  - Response: `{ game }`

### Delete coming soon games

- **DELETE** `/api/comingSoon/:id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ success }`

---

## 📑 News Types

### Get all News Types

- **GET** `/api/newsType`
  - Response: `{ types }`

### Create News Types

- **POST** `/api/newsType`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ name, description }`
  - Response: `{ type }`

### Update News Types

- **PUT** `/api/newsType/:id`

  - Headers: `Authorization: Bearer {token}`
  - body: `{updates}`
  - Response: `{ updates }`

  ### Delete News Types

- **DELETE** `/api/newsType/:id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ success }`

---

## 📝 Game Reviews (مراجعات الألعاب)

### Get all reviews

- **GET** `/api/reviews`
  - Response:
    ```json
    [
      {
        "_id": "64f8a1b2c3d4e5f6g7h8i9j0",
        "userId": {
          "_id": "64f8a1b2c3d4e5f6g7h8i9j0",
          "userName": "GamingCity",
          "userImage": ["https://example.com/avatar.jpg"],
          "firstName": "Game",
          "lastName": "city"
        },
        "title": "مراجعة لعبة Elden Ring",
        "description": "لعبة رائعة جداً وتستحق التجربة...",
        "cover_url": "https://example.com/elden_ring.jpg",
        "average_rating": 4,
        "total_ratings": 150,
        "createdAt": "2023-09-06T12:00:00.000Z"
      }
    ]
    ```

### Get review by ID

- **GET** `/api/reviews/:id`
  - Response: `{ review }`

### Create a new review

- **POST** `/api/reviews`
  - Headers: `Authorization: Bearer {token}`
  - Body (Multipart/form-data):
    - `title`: string
    - `description`: string
    - `cover_url`: file (image)
  - Response: `{ review }`

### Update review

- **PUT** `/api/reviews/:id`
  - Headers: `Authorization: Bearer {token}`
  - Body (Multipart/form-data):
    - `title`: string (optional)
    - `description`: string (optional)
    - `cover_url`: file (optional)
  - Response: `{ review }`

### Delete review

- **DELETE** `/api/reviews/:id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ success: true }`

---

## ⭐ User Ratings (تقييمات المستخدمين)

### Add a rating

- **POST** `/api/userReviews`
  - Headers: `Authorization: Bearer {token}`
  - Body:
    ```json
    {
      "reviewId": "64f8a1b2c3d4e5f6g7h8i9j0",
      "rating": 5
    }
    ```
  - Response: `{ userReview }`

### Get ratings for a review

- **GET** `/api/userReviews/review/:reviewId`
  - Response: `[ { rating, userId, ... } ]`

### Update rating

- **PUT** `/api/userReviews/:id`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ "rating": 4 }`
  - Response: `{ userReview }`

### Delete rating

- **DELETE** `/api/userReviews/:id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ success: true }`

---

## 💬 Review Comments (تعليقات المراجعات)

### Add a comment

- **POST** `/api/reviewComments`
  - Headers: `Authorization: Bearer {token}`
  - Body:
    ```json
    {
      "reviewId": "64f8a1b2c3d4e5f6g7h8i9j0",
      "content": "مراجعة ممتازة، شكراً لك!"
    }
    ```
  - Response: `{ comment }`

### Get comments for a review

- **GET** `/api/reviewComments/review/:reviewId`
  - Response: `[ { content, userId, ... } ]`

### Update comment

- **PUT** `/api/reviewComments/:id`
  - Headers: `Authorization: Bearer {token}`
  - Body: `{ "content": "تحديث التعليق..." }`
  - Response: `{ comment }`

### Delete comment

- **DELETE** `/api/reviewComments/:id`
  - Headers: `Authorization: Bearer {token}`
  - Response: `{ success: true }`

---

## 🎁 Free Games (الألعاب المجانية)

### Get all free games

- **GET** `/api/freeGames`
  - Response:
    ```json
    [
      {
        "id": 123,
        "title": "Mystery Game",
        "worth": "$29.99",
        "image": "https://example.com/game.jpg",
        "open_giveaway_url": "https://example.com/giveaway",
        "status": "Active",
        "end_date": "2023-12-31T23:59:59.000Z"
      }
    ]
    ```

## 🔧 General

### Server health check

- **GET** `/api/`
  - Response: `{ status: "ok", message: "مرحباً بك في API مشروعك الجديد!" }`
