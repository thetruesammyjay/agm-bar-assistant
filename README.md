# AGM BAR - Business Automation & Revenue Platform

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)
![Status](https://img.shields.io/badge/status-MVP-orange.svg)

## 🚀 Overview

AGM BAR (Business Automation & Revenue) is an AI-powered business assistant and automation platform designed to help SMEs automate operations, engage customers, increase sales, and improve overall service efficiency. 

**Multi-Tenant Architecture**: Each business gets its own subdomain (e.g., `coollounge.agmbar.com`) with a personalized AI assistant configured through an interactive onboarding questionnaire. The AI personality adapts to each business's unique vibe, target audience, and service style.

### Key Features

- 🤖 **Personalized AI Chat Assistant** - Unique AI personality for each business based on onboarding questionnaire
- 🏢 **Multi-Tenant Subdomains** - Each business gets their own subdomain (e.g., yourbar.agmbar.com)
- 🍽️ **Smart Menu & Ordering** - Real-time ordering via AI chat with staff notifications
- 📅 **Reservations & Bookings** - Automated table and service reservations
- 🎮 **Engagement & Games** - Interactive games to increase dwell time and spending
- 📱 **QR Code Access** - Scan-to-interact web-based interface (per-business or per-table)
- 📊 **Admin Dashboard** - Business management and analytics
- 🎨 **Custom Branding** - Each business can customize colors, logo, and personality

## 🏗️ Architecture

### Tech Stack

**Frontend**
- React 18+ with Vite / Next.js 14+
- TailwindCSS for styling
- Zustand for state management
- React Query for API calls
- Socket.io-client for real-time updates

**Backend**
- Python 3.11+
- FastAPI
- MySQL 8.0+ (primary database)
- Redis (caching & sessions)
- SQLAlchemy (ORM with PyMySQL)

**AI Integration**
- Groq API (primary LLM provider)
- Google Gemini API (fallback)
- Custom prompt engineering for business contexts

**Deployment**
- Frontend: Vercel / Netlify
- Backend: Railway / Render / DigitalOcean
- Database: PlanetScale / Railway / AWS RDS (MySQL)
- DNS: Cloudflare (for wildcard subdomain support)

## 📋 Prerequisites

- Node.js 18+ and npm/yarn/pnpm
- Python 3.11+
- MySQL 8.0+
- Redis 6+
- Git
- Domain with wildcard DNS support (for subdomains)

## 🛠️ Installation

### 1. Clone the Repository

```bash
git clone https://github.com/thetruesammyjay/agm-bar.git
cd agm-bar
```

### 2. Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
nano .env

# Setup MySQL database
mysql -u root -p
# Then run: source database.sql
# Or import: mysql -u root -p agmbar_db < database.sql

# Run database migrations (if using Alembic)
alembic upgrade head

# Start development server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install
# or
yarn install

# Copy environment file
cp .env.example .env.local

# Edit .env.local with your configuration
nano .env.local

# Start development server
npm run dev
# or
yarn dev
```

The frontend will be available at `http://localhost:5173` (Vite) or `http://localhost:3000` (Next.js)

The backend API will be available at `http://localhost:8000`

## 🔧 Configuration

### Environment Variables

See `.env.example` files in both `backend/` and `frontend/` directories for required configuration.

Key configurations:
- AI API keys (Groq/Gemini)
- Database connection strings
- Redis connection
- WhatsApp/Telegram bot tokens
- JWT secret keys

## 📚 Documentation

- [Database Schema](./database.sql)
- [File Structure](./docs/FILE_STRUCTURE.md)
- [Backend API Endpoints](./docs/BACKEND_API_ENDPOINTS.md)
- [Frontend Implementation Guide](./docs/FRONTEND_IMPLEMENTATION_GUIDE.md)
- [Onboarding Flow & Questionnaire](./docs/ONBOARDING_FLOW.md)
- [Deployment Guide](./docs/DEPLOYMENT.md)

## 🧪 Testing

### Backend Tests
```bash
cd backend
pytest tests/ -v
```

### Frontend Tests
```bash
cd frontend
npm run test
# or
yarn test
```

## 🚢 Deployment

### Backend Deployment (Railway/Render)

1. Connect your GitHub repository
2. Set environment variables in the platform dashboard
3. Deploy with automatic builds from main branch

### Frontend Deployment (Vercel)

```bash
cd frontend
vercel --prod
```

Or connect your GitHub repository to Vercel for automatic deployments.

## 📱 Usage

### For Business Owners

1. **Sign up** at `https://admin.agmbar.com/register`
2. **Complete the onboarding questionnaire** to personalize your AI assistant
3. **Get your subdomain** (e.g., `yourlounge.agmbar.com`)
4. **Configure your menu**, pricing, and branding
5. **Generate and download QR codes** for tables or business locations
6. **Place QR codes** at your venue
7. **Receive orders and reservations** via WhatsApp, Telegram, or dashboard

### For Customers

1. **Scan the QR code** at the business location
2. **Interact with the personalized AI assistant**
3. **Browse menu**, place orders, or make reservations
4. **Play games** while waiting for your order
5. **Receive confirmation** messages
6. **Enjoy your experience!**

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Samuel Justin Ifiezibe**
- GitHub: [@thetruesammyjay](https://github.com/thetruesammyjay)
- Company: AGM Techpluse

## 🙏 Acknowledgments

- Groq AI for fast LLM inference
- Google Gemini for AI capabilities
- FastAPI for excellent backend framework
- React & Vite/Next.js communities

## 📞 Support

For support, email support@agmtechpluse.com or open an issue on GitHub.

## 🗺️ Roadmap

### Phase 1 - MVP (Current)
- [x] Multi-tenant subdomain architecture
- [x] AI personality questionnaire & onboarding
- [x] Personalized AI chat assistant per business
- [x] Menu & ordering system
- [x] Reservations & bookings
- [x] Engagement games
- [x] QR code generation (main + per-table)
- [x] Admin dashboard with branding
- [x] MySQL database with full schema

### Phase 2 - Enhanced Features
- [ ] Voice AI assistant
- [ ] Loyalty program
- [ ] Advanced analytics
- [ ] Payment gateway integration
- [ ] Multi-language support

### Phase 3 - Enterprise
- [ ] White-label solution
- [ ] API marketplace
- [ ] Advanced CRM integration
- [ ] Mobile apps (iOS/Android)

---

**Made with ❤️ by AGM Techpluse**
