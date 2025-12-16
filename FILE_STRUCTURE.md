# AGM BAR - File Structure

## Project Root Structure

```
agm-bar/
├── backend/                      # Python FastAPI backend
├── frontend/                     # React/Vite or Next.js frontend
├── docs/                         # Documentation files
├── .gitignore
├── README.md
├── LICENSE
└── docker-compose.yml           # Optional: Docker setup
```

## Backend Structure (`backend/`)

```
backend/
├── alembic/                     # Database migrations
│   ├── versions/
│   └── env.py
├── app/
│   ├── __init__.py
│   ├── main.py                  # FastAPI application entry point
│   ├── config.py                # Configuration settings
│   ├── dependencies.py          # Dependency injection
│   │
│   ├── api/                     # API routes
│   │   ├── __init__.py
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── router.py        # Main v1 router
│   │   │   ├── auth.py          # Authentication endpoints
│   │   │   ├── ai_chat.py       # AI chat endpoints
│   │   │   ├── menu.py          # Menu management
│   │   │   ├── orders.py        # Order handling
│   │   │   ├── reservations.py  # Reservation endpoints
│   │   │   ├── games.py         # Game endpoints
│   │   │   ├── business.py      # Business management
│   │   │   ├── admin.py         # Admin dashboard
│   │   │   └── webhooks.py      # Webhook handlers
│   │   └── websocket.py         # WebSocket connections
│   │
│   ├── core/                    # Core functionality
│   │   ├── __init__.py
│   │   ├── security.py          # JWT, password hashing
│   │   ├── cache.py             # Redis caching
│   │   ├── database.py          # Database connection
│   │   └── exceptions.py        # Custom exceptions
│   │
│   ├── models/                  # SQLAlchemy models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── business.py
│   │   ├── menu_item.py
│   │   ├── order.py
│   │   ├── reservation.py
│   │   ├── conversation.py
│   │   ├── game_session.py
│   │   └── notification.py
│   │
│   ├── schemas/                 # Pydantic schemas
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── business.py
│   │   ├── menu.py
│   │   ├── order.py
│   │   ├── reservation.py
│   │   ├── chat.py
│   │   └── game.py
│   │
│   ├── services/                # Business logic layer
│   │   ├── __init__.py
│   │   ├── ai_service.py        # AI integration (Groq/Gemini)
│   │   ├── order_service.py
│   │   ├── reservation_service.py
│   │   ├── game_service.py
│   │   ├── notification_service.py
│   │   ├── whatsapp_service.py
│   │   ├── telegram_service.py
│   │   └── qr_service.py
│   │
│   ├── utils/                   # Utility functions
│   │   ├── __init__.py
│   │   ├── validators.py
│   │   ├── helpers.py
│   │   ├── formatters.py
│   │   └── constants.py
│   │
│   └── tests/                   # Backend tests
│       ├── __init__.py
│       ├── conftest.py
│       ├── test_auth.py
│       ├── test_ai_chat.py
│       ├── test_orders.py
│       └── test_reservations.py
│
├── requirements.txt             # Python dependencies
├── requirements-dev.txt         # Development dependencies
├── .env.example                 # Environment variables template
├── .env                         # Actual environment (git-ignored)
├── alembic.ini                  # Alembic configuration
├── pytest.ini                   # Pytest configuration
└── README.md
```

## Frontend Structure (Vite/React)

```
frontend/
├── public/
│   ├── favicon.ico
│   ├── logo.png
│   └── qr-placeholder.png
│
├── src/
│   ├── main.jsx                 # Application entry point
│   ├── App.jsx                  # Root component
│   │
│   ├── assets/                  # Static assets
│   │   ├── images/
│   │   ├── icons/
│   │   └── fonts/
│   │
│   ├── components/              # Reusable components
│   │   ├── common/
│   │   │   ├── Button.jsx
│   │   │   ├── Input.jsx
│   │   │   ├── Modal.jsx
│   │   │   ├── Card.jsx
│   │   │   ├── Loader.jsx
│   │   │   └── QRScanner.jsx
│   │   │
│   │   ├── layout/
│   │   │   ├── Header.jsx
│   │   │   ├── Footer.jsx
│   │   │   ├── Sidebar.jsx
│   │   │   └── AdminLayout.jsx
│   │   │
│   │   ├── chat/
│   │   │   ├── ChatInterface.jsx
│   │   │   ├── MessageBubble.jsx
│   │   │   ├── ChatInput.jsx
│   │   │   └── TypingIndicator.jsx
│   │   │
│   │   ├── menu/
│   │   │   ├── MenuList.jsx
│   │   │   ├── MenuItem.jsx
│   │   │   ├── CategoryFilter.jsx
│   │   │   └── CartSummary.jsx
│   │   │
│   │   ├── reservation/
│   │   │   ├── ReservationForm.jsx
│   │   │   ├── DateTimePicker.jsx
│   │   │   └── ReservationConfirmation.jsx
│   │   │
│   │   ├── games/
│   │   │   ├── GameMenu.jsx
│   │   │   ├── QuizGame.jsx
│   │   │   ├── TruthOrDare.jsx
│   │   │   ├── TriviaGame.jsx
│   │   │   └── GameResults.jsx
│   │   │
│   │   └── admin/
│   │       ├── Dashboard.jsx
│   │       ├── MenuManager.jsx
│   │       ├── OrderList.jsx
│   │       ├── ReservationList.jsx
│   │       ├── BusinessSettings.jsx
│   │       └── Analytics.jsx
│   │
│   ├── pages/                   # Page components
│   │   ├── customer/
│   │   │   ├── HomePage.jsx
│   │   │   ├── MenuPage.jsx
│   │   │   ├── ReservationPage.jsx
│   │   │   ├── GamesPage.jsx
│   │   │   └── ChatPage.jsx
│   │   │
│   │   ├── admin/
│   │   │   ├── LoginPage.jsx
│   │   │   ├── RegisterPage.jsx
│   │   │   ├── DashboardPage.jsx
│   │   │   └── SettingsPage.jsx
│   │   │
│   │   └── NotFoundPage.jsx
│   │
│   ├── hooks/                   # Custom React hooks
│   │   ├── useAuth.js
│   │   ├── useChat.js
│   │   ├── useMenu.js
│   │   ├── useOrders.js
│   │   ├── useReservations.js
│   │   ├── useWebSocket.js
│   │   └── useLocalStorage.js
│   │
│   ├── services/                # API service layer
│   │   ├── api.js               # Axios instance
│   │   ├── authService.js
│   │   ├── chatService.js
│   │   ├── menuService.js
│   │   ├── orderService.js
│   │   ├── reservationService.js
│   │   ├── gameService.js
│   │   └── websocketService.js
│   │
│   ├── store/                   # State management (Zustand)
│   │   ├── authStore.js
│   │   ├── chatStore.js
│   │   ├── cartStore.js
│   │   ├── gameStore.js
│   │   └── uiStore.js
│   │
│   ├── utils/                   # Utility functions
│   │   ├── constants.js
│   │   ├── helpers.js
│   │   ├── validators.js
│   │   └── formatters.js
│   │
│   ├── styles/                  # Global styles
│   │   ├── index.css
│   │   └── tailwind.css
│   │
│   └── config/                  # Configuration
│       ├── routes.jsx
│       └── theme.js
│
├── .env.example                 # Environment variables template
├── .env.local                   # Local environment (git-ignored)
├── .gitignore
├── index.html
├── package.json
├── vite.config.js               # Vite configuration
├── tailwind.config.js           # Tailwind CSS configuration
├── postcss.config.js
└── README.md
```

## Alternative: Next.js Structure

```
frontend/
├── public/
├── src/
│   ├── app/                     # App router (Next.js 13+)
│   │   ├── layout.jsx
│   │   ├── page.jsx
│   │   ├── (customer)/
│   │   │   ├── menu/
│   │   │   ├── reservation/
│   │   │   └── games/
│   │   └── admin/
│   │       ├── dashboard/
│   │       └── settings/
│   │
│   ├── components/              # Same as Vite structure
│   ├── hooks/
│   ├── services/
│   ├── store/
│   └── utils/
│
├── .env.example
├── .env.local
├── next.config.js
├── tailwind.config.js
└── package.json
```

## Documentation Structure (`docs/`)

```
docs/
├── FILE_STRUCTURE.md            # This file
├── BACKEND_API_ENDPOINTS.md     # API documentation
├── FRONTEND_IMPLEMENTATION_GUIDE.md
├── DEPLOYMENT.md
├── CONTRIBUTING.md
└── CHANGELOG.md
```

## Key Files Description

### Backend
- **main.py**: FastAPI application initialization and middleware
- **config.py**: Environment variables and configuration management
- **models/**: Database table definitions using SQLAlchemy
- **schemas/**: Request/response validation using Pydantic
- **services/**: Business logic and external API integration
- **api/v1/**: REST API endpoint handlers

### Frontend
- **main.jsx / App.jsx**: Application entry and root component
- **pages/**: Full page components with routing
- **components/**: Reusable UI components
- **hooks/**: Custom React hooks for shared logic
- **services/**: API communication layer
- **store/**: Global state management

## Development Workflow

1. **Backend Development**
   - Create models in `models/`
   - Define schemas in `schemas/`
   - Implement business logic in `services/`
   - Create API endpoints in `api/v1/`
   - Write tests in `tests/`

2. **Frontend Development**
   - Create API service functions in `services/`
   - Build reusable components in `components/`
   - Create page components in `pages/`
   - Implement state management in `store/`
   - Style with Tailwind CSS

3. **Integration**
   - Connect frontend services to backend endpoints
   - Test WebSocket connections
   - Implement error handling
   - Add loading states and user feedback

## Version Control

### Git Ignore Patterns

Backend:
```
__pycache__/
*.py[cod]
venv/
.env
*.db
*.log
```

Frontend:
```
node_modules/
.env.local
dist/
build/
.next/
```

## Notes

- Keep components small and focused (single responsibility)
- Use absolute imports where possible
- Follow naming conventions consistently
- Document complex logic with comments
- Write tests for critical functionality
