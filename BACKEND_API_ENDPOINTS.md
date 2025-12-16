# AGM BAR - Backend API Endpoints

**Base URL**: `http://localhost:8000/api/v1`  
**Production**: `https://api.agmbar.com/api/v1`

## Authentication

All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

---

## 1. Authentication & User Management

### 1.1 Register Business (with Subdomain)
```http
POST /auth/register
```

**Request Body**:
```json
{
  "business_name": "Cool Lounge",
  "business_type": "lounge",
  "email": "admin@coollounge.com",
  "password": "securePassword123",
  "full_name": "John Doe",
  "phone": "+2348012345678",
  "address": "123 Main Street",
  "city": "Lagos",
  "state": "Lagos",
  "country": "Nigeria"
}
```

**Response** (201):
```json
{
  "user": {
    "id": "uuid",
    "email": "admin@coollounge.com",
    "full_name": "John Doe",
    "role": "owner"
  },
  "business": {
    "id": "uuid",
    "business_name": "Cool Lounge",
    "subdomain": "cool-lounge",
    "url": "https://cool-lounge.agmbar.com",
    "onboarding_completed": false
  },
  "access_token": "jwt_token",
  "token_type": "bearer"
}
```

**Notes**: 
- Subdomain is auto-generated from business_name
- If subdomain exists, adds number: "cool-lounge-2"
- User must complete onboarding questionnaire next

### 1.2 Login
```http
POST /auth/login
```

**Request Body**:
```json
{
  "email": "admin@example.com",
  "password": "securePassword123"
}
```

**Response** (200):
```json
{
  "access_token": "jwt_token",
  "token_type": "bearer",
  "user": {
    "id": "uuid",
    "email": "admin@example.com",
    "full_name": "John Doe",
    "role": "admin"
  }
}
```

### 1.3 Get Current User
```http
GET /auth/me
```
**Auth Required**: Yes

**Response** (200):
```json
{
  "id": "uuid",
  "email": "admin@example.com",
  "full_name": "John Doe",
  "role": "admin",
  "business_id": "uuid"
}
```

### 1.4 Refresh Token
```http
POST /auth/refresh
```

**Request Body**:
```json
{
  "refresh_token": "refresh_jwt_token"
}
```

---

## 2. Onboarding & Questionnaire

### 2.1 Submit Onboarding Questionnaire
```http
POST /onboarding/questionnaire
```
**Auth Required**: Yes

**Request Body**:
```json
{
  "business_atmosphere": "lively",
  "target_audience": "young professionals, students",
  "price_range": "moderate",
  
  "preferred_ai_name": "Alex",
  "ai_gender": "neutral",
  "personality_type": "friendly",
  
  "friendliness_level": 8,
  "formality_level": 5,
  "humor_level": 6,
  "chattiness_level": 7,
  "use_emojis": true,
  "use_local_slang": false,
  "response_length": "moderate",
  
  "signature_items": [
    "Famous cocktails",
    "Live music every Friday"
  ],
  "house_specialties": [
    "Grilled Chicken Wings",
    "Mojito Supreme"
  ],
  "customer_favorites": "Happy hour specials",
  
  "dress_code": "Smart casual",
  "age_restrictions": "18+ after 9 PM",
  "special_policies": "No outside food",
  
  "primary_goal": "all",
  "upsell_strategy": "moderate",
  "service_speed": "standard",
  "interaction_preference": "helpful",
  "additional_instructions": "Always mention daily specials"
}
```

**Response** (201):
```json
{
  "success": true,
  "message": "AI personality created successfully",
  "ai_personality": {
    "personality_name": "Alex",
    "greeting_message": "Hey there! 👋 Welcome to Cool Lounge!...",
    "personality_type": "friendly"
  },
  "business": {
    "onboarding_completed": true,
    "subdomain": "cool-lounge",
    "url": "https://cool-lounge.agmbar.com"
  }
}
```

### 2.2 Get Onboarding Status
```http
GET /onboarding/status
```
**Auth Required**: Yes

**Response** (200):
```json
{
  "completed": false,
  "steps_completed": ["registration"],
  "next_step": "questionnaire"
}
```

### 2.3 Preview AI Personality
```http
POST /onboarding/preview
```
**Auth Required**: Yes

**Request Body**:
```json
{
  "personality_type": "friendly",
  "friendliness_level": 8,
  "use_emojis": true,
  "sample_question": "What's on the menu?"
}
```

**Response** (200):
```json
{
  "greeting": "Hey there! 👋 Welcome to Cool Lounge!",
  "sample_response": "Great question! We've got some amazing options...",
  "tone_analysis": "Friendly, warm, enthusiastic"
}
```

---

## 3. AI Chat Assistant

### 2.1 Send Message to AI
```http
POST /chat/message
```

**Request Body**:
```json
{
  "business_id": "uuid",
  "session_id": "uuid",
  "message": "What's on the menu?",
  "context": {
    "user_name": "Guest",
    "table_number": "5"
  }
}
```

**Response** (200):
```json
{
  "response": "Here's what we have available...",
  "intent": "menu_inquiry",
  "suggested_actions": [
    {
      "type": "view_menu",
      "label": "View Full Menu"
    }
  ],
  "conversation_id": "uuid"
}
```

### 2.2 Get Conversation History
```http
GET /chat/conversations/{conversation_id}
```

**Response** (200):
```json
{
  "id": "uuid",
  "business_id": "uuid",
  "messages": [
    {
      "role": "user",
      "content": "Hello",
      "timestamp": "2025-01-15T10:30:00Z"
    },
    {
      "role": "assistant",
      "content": "Hi! How can I help you?",
      "timestamp": "2025-01-15T10:30:02Z"
    }
  ],
  "created_at": "2025-01-15T10:30:00Z"
}
```

### 2.3 Start New Session
```http
POST /chat/sessions
```

**Request Body**:
```json
{
  "business_id": "uuid",
  "user_identifier": "table_5_guest"
}
```

---

## 4. Menu Management

### 4.1 Get Menu (Public - by subdomain)
```http
GET /menu/{subdomain}
```
**OR**
```http
GET /menu/business/{business_id}
```

**Query Parameters**:
- `category`: string (optional) - Filter by category
- `available_only`: boolean (default: true)

**Response** (200):
```json
{
  "business": {
    "id": "uuid",
    "name": "Cool Lounge",
    "subdomain": "cool-lounge"
  },
  "categories": [
    {
      "id": "uuid",
      "name": "Drinks",
      "items": [
        {
          "id": "uuid",
          "name": "Mojito",
          "description": "Fresh mint mojito",
          "price": 2500,
          "currency": "NGN",
          "image_url": "https://...",
          "available": true,
          "category": "Drinks"
        }
      ]
    }
  ]
}
```

### 4.2 Create Menu Item
```http
POST /menu/items
```
**Auth Required**: Yes (Admin)

**Request Body**:
```json
{
  "name": "Grilled Chicken",
  "description": "Tender grilled chicken with spices",
  "price": 3500,
  "category_id": "uuid",
  "image_url": "https://...",
  "available": true,
  "preparation_time_minutes": 20,
  "is_vegetarian": false,
  "allergens": ["gluten"]
}
```

**Response** (201):
```json
{
  "id": "uuid",
  "name": "Grilled Chicken",
  "description": "Tender grilled chicken with spices",
  "price": 3500,
  "category": "Food",
  "created_at": "2025-01-15T10:00:00Z"
}
```

### 4.3 Update Menu Item
```http
PUT /menu/items/{item_id}
```
**Auth Required**: Yes (Admin)

### 4.4 Delete Menu Item
```http
DELETE /menu/items/{item_id}
```
**Auth Required**: Yes (Admin)

### 4.5 Toggle Item Availability
```http
PATCH /menu/items/{item_id}/availability
```
**Auth Required**: Yes (Admin)

**Request Body**:
```json
{
  "available": false
}
```

### 4.6 Create Menu Category
```http
POST /menu/categories
```
**Auth Required**: Yes (Admin)

**Request Body**:
```json
{
  "name": "Appetizers",
  "description": "Start your meal right",
  "display_order": 1
}
```

---

## 5. Orders

### 4.1 Create Order
```http
POST /orders
```

**Request Body**:
```json
{
  "business_id": "uuid",
  "customer_name": "John Doe",
  "table_number": "5",
  "items": [
    {
      "menu_item_id": "uuid",
      "quantity": 2,
      "special_instructions": "No ice"
    }
  ],
  "order_type": "dine_in",
  "phone": "+2348012345678"
}
```

**Response** (201):
```json
{
  "id": "uuid",
  "order_number": "ORD-001",
  "business_id": "uuid",
  "customer_name": "John Doe",
  "total_amount": 5000,
  "status": "pending",
  "items": [...],
  "created_at": "2025-01-15T11:00:00Z"
}
```

### 5.2 Get Orders (Admin)
```http
GET /orders
```
**Auth Required**: Yes (Admin)

**Query Parameters**:
- `status`: string (pending, confirmed, preparing, ready, delivered, cancelled)
- `date_from`: date
- `date_to`: date
- `page`: int (default: 1)
- `limit`: int (default: 20)

**Response** (200):
```json
{
  "orders": [...],
  "total": 50,
  "page": 1,
  "pages": 3
}
```

### 5.3 Get Order by ID
```http
GET /orders/{order_id}
```
**Auth Required**: Yes (Admin)

### 5.4 Update Order Status
```http
PATCH /orders/{order_id}/status
```
**Auth Required**: Yes (Admin)

**Request Body**:
```json
{
  "status": "preparing"
}
```

### 5.5 Cancel Order
```http
DELETE /orders/{order_id}
```
**Auth Required**: Yes (Admin)

---

## 6. Reservations

### 5.1 Create Reservation
```http
POST /reservations
```

**Request Body**:
```json
{
  "business_id": "uuid",
  "customer_name": "Jane Smith",
  "phone": "+2348012345678",
  "email": "jane@example.com",
  "date": "2025-01-20",
  "time": "19:00",
  "party_size": 4,
  "special_requests": "Window seat preferred"
}
```

**Response** (201):
```json
{
  "id": "uuid",
  "reservation_code": "RES-12345",
  "business_id": "uuid",
  "customer_name": "Jane Smith",
  "date": "2025-01-20",
  "time": "19:00:00",
  "party_size": 4,
  "status": "pending",
  "created_at": "2025-01-15T12:00:00Z"
}
```

### 6.2 Get Reservations (Admin)
```http
GET /reservations
```
**Auth Required**: Yes (Admin)

**Query Parameters**:
- `status`: string (pending, confirmed, cancelled, completed)
- `date_from`: date
- `date_to`: date

### 6.3 Update Reservation Status
```http
PATCH /reservations/{reservation_id}/status
```
**Auth Required**: Yes (Admin)

**Request Body**:
```json
{
  "status": "confirmed"
}
```

### 6.4 Cancel Reservation
```http
DELETE /reservations/{reservation_id}
```

---

## 7. Games & Engagement

### 6.1 Get Available Games
```http
GET /games/{business_id}
```

**Response** (200):
```json
{
  "games": [
    {
      "id": "quiz",
      "name": "Quick Quiz",
      "description": "Test your knowledge",
      "type": "solo",
      "difficulty": "medium"
    },
    {
      "id": "truth_or_dare",
      "name": "Truth or Dare",
      "description": "Fun party game",
      "type": "group",
      "min_players": 2
    }
  ]
}
```

### 7.2 Start Game Session
```http
POST /games/sessions
```

**Request Body**:
```json
{
  "game_id": "quiz",
  "business_id": "uuid",
  "session_id": "uuid",
  "difficulty": "medium"
}
```

**Response** (201):
```json
{
  "session_id": "uuid",
  "game_id": "quiz",
  "question": {
    "id": "uuid",
    "text": "What is the capital of Nigeria?",
    "options": ["Lagos", "Abuja", "Port Harcourt", "Kano"],
    "type": "multiple_choice"
  },
  "score": 0,
  "questions_answered": 0
}
```

### 7.3 Submit Game Answer
```http
POST /games/sessions/{session_id}/answer
```

**Request Body**:
```json
{
  "question_id": "uuid",
  "answer": "Abuja"
}
```

**Response** (200):
```json
{
  "correct": true,
  "score": 10,
  "total_score": 10,
  "next_question": {...},
  "game_completed": false
}
```

### 7.4 Get Game Leaderboard
```http
GET /games/leaderboard/{business_id}
```

**Query Parameters**:
- `game_id`: string
- `period`: string (today, week, month, all_time)

---

## 8. Business Management

### 7.1 Get Business Profile
```http
GET /business/{business_id}
```

**Response** (200):
```json
{
  "id": "uuid",
  "name": "Cool Lounge",
  "type": "lounge",
  "description": "The best lounge in town",
  "phone": "+2348012345678",
  "email": "info@coollounge.com",
  "address": "123 Main Street, Lagos",
  "logo_url": "https://...",
  "qr_code_url": "https://...",
  "settings": {
    "ai_personality": "friendly",
    "enable_games": true,
    "enable_reservations": true,
    "enable_ordering": true
  }
}
```

### 7.2 Update Business Profile
```http
PUT /business/{business_id}
```
**Auth Required**: Yes (Admin)

**Request Body**:
```json
{
  "description": "Updated description",
  "phone": "+2348012345678",
  "address": "New address"
}
```

### 7.3 Update Business Settings
```http
PATCH /business/{business_id}/settings
```
**Auth Required**: Yes (Admin)

**Request Body**:
```json
{
  "ai_personality": "professional",
  "enable_games": false,
  "operating_hours": {
    "monday": {"open": "09:00", "close": "22:00"},
    "tuesday": {"open": "09:00", "close": "22:00"}
  }
}
```

### 7.4 Generate QR Code
```http
POST /business/{business_id}/qr-code
```
**Auth Required**: Yes (Admin)

**Request Body**:
```json
{
  "size": 300,
  "table_number": "5"
}
```

**Response** (200):
```json
{
  "qr_code_url": "https://...",
  "qr_code_data": "base64_encoded_image"
}
```

---

## 9. Admin Dashboard

### 9.1 Get Dashboard Stats
```http
GET /admin/dashboard/stats
```
**Auth Required**: Yes (Admin)

**Response** (200):
```json
{
  "today": {
    "orders": 45,
    "revenue": 125000,
    "reservations": 12,
    "active_sessions": 8
  },
  "week": {
    "orders": 320,
    "revenue": 890000,
    "reservations": 85,
    "growth_rate": 12.5
  },
  "popular_items": [
    {
      "name": "Mojito",
      "orders": 78
    }
  ]
}
```

### 9.2 Get Activity Feed
```http
GET /admin/dashboard/activity
```
**Auth Required**: Yes (Admin)

**Query Parameters**:
- `limit`: int (default: 20)

**Response** (200):
```json
{
  "activities": [
    {
      "type": "new_order",
      "description": "New order #ORD-045 from Table 3",
      "timestamp": "2025-01-15T14:30:00Z"
    }
  ]
}
```

---

## 10. Notifications

### 9.1 Configure Notification Channels
```http
POST /notifications/channels
```
**Auth Required**: Yes (Admin)

**Request Body**:
```json
{
  "whatsapp": {
    "enabled": true,
    "phone": "+2348012345678"
  },
  "telegram": {
    "enabled": true,
    "chat_id": "123456789"
  },
  "email": {
    "enabled": true,
    "address": "admin@example.com"
  }
}
```

### 10.2 Get Notification Settings
```http
GET /notifications/settings
```
**Auth Required**: Yes (Admin)

### 10.3 Test Notification
```http
POST /notifications/test
```
**Auth Required**: Yes (Admin)

**Request Body**:
```json
{
  "channel": "whatsapp",
  "message": "Test notification"
}
```

---

## 11. WebSocket Endpoints

### 11.1 Real-time Order Updates
```
ws://localhost:8000/ws/orders/{business_id}
```

**Events**:
- `new_order`: New order created
- `order_updated`: Order status changed
- `order_cancelled`: Order cancelled

### 11.2 Real-time Chat
```
ws://localhost:8000/ws/chat/{session_id}
```

**Events**:
- `message`: New message from user or AI
- `typing`: User or AI is typing
- `session_ended`: Chat session ended

---

## Error Responses

All endpoints follow this error response format:

```json
{
  "detail": "Error message",
  "error_code": "ERROR_CODE",
  "status_code": 400
}
```

### Common HTTP Status Codes

- **200**: Success
- **201**: Created
- **400**: Bad Request
- **401**: Unauthorized
- **403**: Forbidden
- **404**: Not Found
- **422**: Validation Error
- **500**: Internal Server Error

### Example Validation Error (422):
```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

---

## Rate Limiting

- **Anonymous users**: 60 requests/minute
- **Authenticated users**: 200 requests/minute
- **Admin users**: 500 requests/minute

Rate limit headers:
```
X-RateLimit-Limit: 200
X-RateLimit-Remaining: 150
X-RateLimit-Reset: 1642329600
```

---

## Testing with curl

### Example: Get Menu
```bash
curl -X GET "http://localhost:8000/api/v1/menu/business-uuid" \
  -H "Accept: application/json"
```

### Example: Create Order with Auth
```bash
curl -X POST "http://localhost:8000/api/v1/orders" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "business_id": "uuid",
    "customer_name": "John",
    "items": [{"menu_item_id": "uuid", "quantity": 2}]
  }'
```
