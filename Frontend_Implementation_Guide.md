# AGM BAR - Frontend Implementation Guide

## Table of Contents
1. [Tech Stack & Dependencies](#tech-stack--dependencies)
2. [Project Setup](#project-setup)
3. [Architecture Overview](#architecture-overview)
4. [Core Features Implementation](#core-features-implementation)
5. [State Management](#state-management)
6. [API Integration](#api-integration)
7. [WebSocket Integration](#websocket-integration)
8. [Styling Guidelines](#styling-guidelines)
9. [Best Practices](#best-practices)

---

## Tech Stack & Dependencies

### Core Technologies
- **React 18+**: UI framework
- **Vite / Next.js 14+**: Build tool / Framework
- **TailwindCSS**: Styling
- **TypeScript** (optional but recommended)

### Key Libraries

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "zustand": "^4.4.7",
    "@tanstack/react-query": "^5.14.2",
    "axios": "^1.6.2",
    "socket.io-client": "^4.6.1",
    "react-hook-form": "^7.49.2",
    "zod": "^3.22.4",
    "date-fns": "^2.30.0",
    "react-hot-toast": "^2.4.1",
    "lucide-react": "^0.294.0",
    "qr-scanner": "^1.4.2",
    "framer-motion": "^10.16.16"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.1",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32",
    "vite": "^5.0.8"
  }
}
```

---

## Project Setup

### 1. Initialize Vite Project

```bash
npm create vite@latest agm-bar-frontend -- --template react
cd agm-bar-frontend
npm install
```

### 2. Install Dependencies

```bash
# Core dependencies
npm install react-router-dom zustand @tanstack/react-query axios socket.io-client

# Form handling
npm install react-hook-form zod @hookform/resolvers

# UI utilities
npm install date-fns react-hot-toast lucide-react framer-motion

# Development
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### 3. Configure TailwindCSS

**tailwind.config.js**:
```javascript
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
        secondary: {
          500: '#8b5cf6',
          600: '#7c3aed',
        }
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        }
      }
    },
  },
  plugins: [],
}
```

### 4. Environment Configuration

**src/config/env.js**:
```javascript
export const config = {
  apiUrl: import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1',
  wsUrl: import.meta.env.VITE_WS_URL || 'ws://localhost:8000/ws',
  appName: 'AGM BAR',
  version: '1.0.0',
}
```

---

## Architecture Overview

### Component Structure

```
Components should be:
- Small and focused (single responsibility)
- Reusable across different pages
- Well-documented with JSDoc comments
- Type-safe (if using TypeScript)
```

### Folder Organization

```
src/
├── components/     # Reusable UI components
├── pages/          # Route-level components
├── hooks/          # Custom React hooks
├── services/       # API & external services
├── store/          # Global state (Zustand)
├── utils/          # Helper functions
└── config/         # Configuration files
```

---

## Core Features Implementation

### 1. AI Chat Interface

**components/chat/ChatInterface.jsx**:
```jsx
import { useState, useEffect, useRef } from 'react'
import { useChatStore } from '@/store/chatStore'
import { chatService } from '@/services/chatService'
import MessageBubble from './MessageBubble'
import ChatInput from './ChatInput'
import { Loader2 } from 'lucide-react'

export default function ChatInterface({ businessId }) {
  const [messages, setMessages] = useState([])
  const [isLoading, setIsLoading] = useState(false)
  const messagesEndRef = useRef(null)
  
  const { sessionId, createSession } = useChatStore()

  useEffect(() => {
    if (!sessionId) {
      createSession(businessId)
    }
  }, [businessId, sessionId, createSession])

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const handleSendMessage = async (message) => {
    // Add user message immediately
    const userMessage = {
      role: 'user',
      content: message,
      timestamp: new Date().toISOString()
    }
    setMessages(prev => [...prev, userMessage])

    setIsLoading(true)
    try {
      const response = await chatService.sendMessage({
        business_id: businessId,
        session_id: sessionId,
        message
      })

      const aiMessage = {
        role: 'assistant',
        content: response.response,
        timestamp: new Date().toISOString(),
        suggestedActions: response.suggested_actions
      }
      setMessages(prev => [...prev, aiMessage])
    } catch (error) {
      console.error('Failed to send message:', error)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="flex flex-col h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b px-4 py-3 shadow-sm">
        <h2 className="text-lg font-semibold">AI Assistant</h2>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((msg, idx) => (
          <MessageBubble key={idx} message={msg} />
        ))}
        {isLoading && (
          <div className="flex items-center gap-2 text-gray-500">
            <Loader2 className="w-4 h-4 animate-spin" />
            <span>AI is thinking...</span>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <ChatInput onSend={handleSendMessage} disabled={isLoading} />
    </div>
  )
}
```

**components/chat/ChatInput.jsx**:
```jsx
import { useState } from 'react'
import { Send } from 'lucide-react'

export default function ChatInput({ onSend, disabled }) {
  const [input, setInput] = useState('')

  const handleSubmit = (e) => {
    e.preventDefault()
    if (input.trim() && !disabled) {
      onSend(input.trim())
      setInput('')
    }
  }

  return (
    <form onSubmit={handleSubmit} className="bg-white border-t p-4">
      <div className="flex gap-2">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Type your message..."
          disabled={disabled}
          className="flex-1 px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 disabled:bg-gray-100"
        />
        <button
          type="submit"
          disabled={disabled || !input.trim()}
          className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          <Send className="w-5 h-5" />
        </button>
      </div>
    </form>
  )
}
```

### 2. Menu Display & Ordering

**components/menu/MenuList.jsx**:
```jsx
import { useQuery } from '@tanstack/react-query'
import { menuService } from '@/services/menuService'
import MenuItem from './MenuItem'
import { useCartStore } from '@/store/cartStore'
import { Loader2 } from 'lucide-react'

export default function MenuList({ businessId }) {
  const { data: menu, isLoading, error } = useQuery({
    queryKey: ['menu', businessId],
    queryFn: () => menuService.getMenu(businessId)
  })

  const addToCart = useCartStore(state => state.addItem)

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="w-8 h-8 animate-spin text-primary-600" />
      </div>
    )
  }

  if (error) {
    return (
      <div className="text-center text-red-600 p-4">
        Failed to load menu. Please try again.
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {menu?.categories?.map((category) => (
        <div key={category.id}>
          <h2 className="text-2xl font-bold mb-4">{category.name}</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {category.items.map((item) => (
              <MenuItem
                key={item.id}
                item={item}
                onAddToCart={() => addToCart(item)}
              />
            ))}
          </div>
        </div>
      ))}
    </div>
  )
}
```

**components/menu/MenuItem.jsx**:
```jsx
import { ShoppingCart } from 'lucide-react'

export default function MenuItem({ item, onAddToCart }) {
  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
      {item.image_url && (
        <img
          src={item.image_url}
          alt={item.name}
          className="w-full h-48 object-cover"
        />
      )}
      <div className="p-4">
        <h3 className="font-semibold text-lg mb-2">{item.name}</h3>
        <p className="text-gray-600 text-sm mb-3">{item.description}</p>
        <div className="flex items-center justify-between">
          <span className="text-xl font-bold text-primary-600">
            ₦{item.price.toLocaleString()}
          </span>
          <button
            onClick={onAddToCart}
            disabled={!item.available}
            className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors flex items-center gap-2"
          >
            <ShoppingCart className="w-4 h-4" />
            Add
          </button>
        </div>
      </div>
    </div>
  )
}
```

### 3. Reservation Form

**components/reservation/ReservationForm.jsx**:
```jsx
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useMutation } from '@tanstack/react-query'
import { reservationService } from '@/services/reservationService'
import toast from 'react-hot-toast'

const reservationSchema = z.object({
  customer_name: z.string().min(2, 'Name must be at least 2 characters'),
  phone: z.string().regex(/^\+?[1-9]\d{9,14}$/, 'Invalid phone number'),
  email: z.string().email('Invalid email').optional(),
  date: z.string().min(1, 'Date is required'),
  time: z.string().min(1, 'Time is required'),
  party_size: z.number().min(1).max(20),
  special_requests: z.string().optional()
})

export default function ReservationForm({ businessId, onSuccess }) {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(reservationSchema)
  })

  const mutation = useMutation({
    mutationFn: reservationService.createReservation,
    onSuccess: (data) => {
      toast.success('Reservation confirmed!')
      onSuccess?.(data)
    },
    onError: (error) => {
      toast.error(error.message || 'Failed to create reservation')
    }
  })

  const onSubmit = (data) => {
    mutation.mutate({ ...data, business_id: businessId })
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label className="block text-sm font-medium mb-1">Full Name</label>
        <input
          {...register('customer_name')}
          className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
        />
        {errors.customer_name && (
          <p className="text-red-500 text-sm mt-1">{errors.customer_name.message}</p>
        )}
      </div>

      <div>
        <label className="block text-sm font-medium mb-1">Phone</label>
        <input
          {...register('phone')}
          placeholder="+2348012345678"
          className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
        />
        {errors.phone && (
          <p className="text-red-500 text-sm mt-1">{errors.phone.message}</p>
        )}
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium mb-1">Date</label>
          <input
            type="date"
            {...register('date')}
            min={new Date().toISOString().split('T')[0]}
            className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
          />
          {errors.date && (
            <p className="text-red-500 text-sm mt-1">{errors.date.message}</p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Time</label>
          <input
            type="time"
            {...register('time')}
            className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
          />
          {errors.time && (
            <p className="text-red-500 text-sm mt-1">{errors.time.message}</p>
          )}
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium mb-1">Party Size</label>
        <input
          type="number"
          {...register('party_size', { valueAsNumber: true })}
          min="1"
          max="20"
          className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
        />
        {errors.party_size && (
          <p className="text-red-500 text-sm mt-1">{errors.party_size.message}</p>
        )}
      </div>

      <button
        type="submit"
        disabled={mutation.isPending}
        className="w-full py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 font-medium transition-colors"
      >
        {mutation.isPending ? 'Confirming...' : 'Confirm Reservation'}
      </button>
    </form>
  )
}
```

### 4. Game Interface

**components/games/QuizGame.jsx**:
```jsx
import { useState, useEffect } from 'react'
import { gameService } from '@/services/gameService'
import { Trophy, Clock } from 'lucide-react'

export default function QuizGame({ businessId }) {
  const [session, setSession] = useState(null)
  const [selectedAnswer, setSelectedAnswer] = useState(null)
  const [timer, setTimer] = useState(30)

  useEffect(() => {
    startGame()
  }, [])

  useEffect(() => {
    if (timer > 0 && session && !session.game_completed) {
      const interval = setInterval(() => {
        setTimer(t => t - 1)
      }, 1000)
      return () => clearInterval(interval)
    }
  }, [timer, session])

  const startGame = async () => {
    const data = await gameService.startGame({
      game_id: 'quiz',
      business_id: businessId,
      difficulty: 'medium'
    })
    setSession(data)
    setTimer(30)
  }

  const handleAnswer = async (answer) => {
    setSelectedAnswer(answer)
    const result = await gameService.submitAnswer(session.session_id, {
      question_id: session.question.id,
      answer
    })

    setTimeout(() => {
      if (result.game_completed) {
        // Show final score
        setSession({ ...session, game_completed: true, total_score: result.total_score })
      } else {
        setSession(prev => ({
          ...prev,
          question: result.next_question,
          score: result.total_score
        }))
        setSelectedAnswer(null)
        setTimer(30)
      }
    }, 1500)
  }

  if (!session) return <div>Loading...</div>

  if (session.game_completed) {
    return (
      <div className="text-center p-8">
        <Trophy className="w-20 h-20 mx-auto text-yellow-500 mb-4" />
        <h2 className="text-3xl font-bold mb-2">Game Over!</h2>
        <p className="text-2xl text-primary-600 mb-6">
          Score: {session.total_score}
        </p>
        <button
          onClick={startGame}
          className="px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
        >
          Play Again
        </button>
      </div>
    )
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div className="flex items-center gap-2">
          <Trophy className="w-6 h-6 text-yellow-500" />
          <span className="font-bold text-xl">Score: {session.score}</span>
        </div>
        <div className="flex items-center gap-2">
          <Clock className="w-5 h-5" />
          <span className={`font-bold ${timer < 10 ? 'text-red-600' : ''}`}>
            {timer}s
          </span>
        </div>
      </div>

      {/* Question */}
      <div className="bg-white rounded-lg p-6 shadow-md">
        <h3 className="text-xl font-semibold mb-4">{session.question.text}</h3>
        
        <div className="space-y-3">
          {session.question.options.map((option, idx) => (
            <button
              key={idx}
              onClick={() => handleAnswer(option)}
              disabled={selectedAnswer !== null}
              className={`w-full p-4 text-left rounded-lg border-2 transition-all ${
                selectedAnswer === option
                  ? 'border-primary-600 bg-primary-50'
                  : 'border-gray-200 hover:border-primary-300'
              } disabled:cursor-not-allowed`}
            >
              {option}
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}
```

---

## State Management

### Zustand Store Examples

**store/authStore.js**:
```javascript
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export const useAuthStore = create(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,

      setAuth: (user, token) => set({
        user,
        token,
        isAuthenticated: true
      }),

      logout: () => set({
        user: null,
        token: null,
        isAuthenticated: false
      }),

      updateUser: (userData) => set((state) => ({
        user: { ...state.user, ...userData }
      }))
    }),
    {
      name: 'auth-storage',
    }
  )
)
```

**store/cartStore.js**:
```javascript
import { create } from 'zustand'

export const useCartStore = create((set, get) => ({
  items: [],
  total: 0,

  addItem: (item) => set((state) => {
    const existing = state.items.find(i => i.id === item.id)
    if (existing) {
      return {
        items: state.items.map(i =>
          i.id === item.id ? { ...i, quantity: i.quantity + 1 } : i
        )
      }
    }
    return {
      items: [...state.items, { ...item, quantity: 1 }]
    }
  }),

  removeItem: (itemId) => set((state) => ({
    items: state.items.filter(i => i.id !== itemId)
  })),

  updateQuantity: (itemId, quantity) => set((state) => ({
    items: state.items.map(i =>
      i.id === itemId ? { ...i, quantity } : i
    )
  })),

  clearCart: () => set({ items: [], total: 0 }),

  calculateTotal: () => {
    const items = get().items
    const total = items.reduce((sum, item) =>
      sum + (item.price * item.quantity), 0
    )
    set({ total })
  }
}))
```

---

## API Integration

### API Service Setup

**services/api.js**:
```javascript
import axios from 'axios'
import { config } from '@/config/env'
import { useAuthStore } from '@/store/authStore'

const api = axios.create({
  baseURL: config.apiUrl,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    const token = useAuthStore.getState().token
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor
api.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      useAuthStore.getState().logout()
      window.location.href = '/admin/login'
    }
    return Promise.reject(error.response?.data || error.message)
  }
)

export default api
```

---

## WebSocket Integration

**services/websocketService.js**:
```javascript
import io from 'socket.io-client'
import { config } from '@/config/env'

class WebSocketService {
  constructor() {
    this.socket = null
  }

  connect(businessId, token) {
    this.socket = io(config.wsUrl, {
      auth: { token },
      query: { business_id: businessId }
    })

    this.socket.on('connect', () => {
      console.log('WebSocket connected')
    })

    this.socket.on('disconnect', () => {
      console.log('WebSocket disconnected')
    })

    return this.socket
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect()
      this.socket = null
    }
  }

  on(event, callback) {
    if (this.socket) {
      this.socket.on(event, callback)
    }
  }

  emit(event, data) {
    if (this.socket) {
      this.socket.emit(event, data)
    }
  }
}

export default new WebSocketService()
```

---

## Styling Guidelines

### TailwindCSS Best Practices

1. **Use utility classes first**
2. **Create component classes for repeated patterns**
3. **Use CSS custom properties for theme values**
4. **Responsive design with mobile-first approach**

### Example Component Styles

```jsx
// Good: Utility classes
<button className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors">
  Click Me
</button>

// Better: Extracted to reusable component
<Button variant="primary">Click Me</Button>
```

---

## Best Practices

### 1. Error Handling
```jsx
import toast from 'react-hot-toast'

try {
  await someAsyncOperation()
  toast.success('Operation successful')
} catch (error) {
  toast.error(error.message || 'Something went wrong')
}
```

### 2. Loading States
```jsx
const { data, isLoading, error } = useQuery(...)

if (isLoading) return <Loader />
if (error) return <ErrorMessage error={error} />
return <Content data={data} />
```

### 3. Performance Optimization
- Use React.memo for expensive components
- Implement code splitting with lazy loading
- Optimize images (use WebP, lazy load)
- Debounce search inputs

### 4. Accessibility
- Use semantic HTML
- Add ARIA labels where needed
- Ensure keyboard navigation
- Maintain color contrast ratios

---

This guide provides a solid foundation for building the AGM BAR frontend. Adjust and expand based on your specific needs!
