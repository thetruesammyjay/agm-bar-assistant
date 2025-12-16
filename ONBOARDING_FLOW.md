# AGM BAR - Onboarding Flow & Questionnaire

## Overview

The onboarding process is designed to:
1. Collect business information
2. Set up subdomain (e.g., coollounge.agmbar.com)
3. Create personalized AI assistant through questionnaire
4. Configure business settings
5. Generate QR codes

---

## Onboarding Steps

### Step 1: Business Registration (Sign Up)

**Endpoint**: `POST /api/v1/auth/register`

**Form Fields**:
```javascript
{
  business_name: "Cool Lounge",
  business_type: "lounge", // bar, restaurant, cafe, hotel
  email: "owner@coollounge.com",
  phone: "+2348012345678",
  password: "secure_password",
  full_name: "John Doe",
  
  // Location
  address: "123 Main Street",
  city: "Lagos",
  state: "Lagos",
  country: "Nigeria"
}
```

**Backend Process**:
1. Validate email uniqueness
2. Generate subdomain from business_name
   - "Cool Lounge" → "cool-lounge"
   - Check if available, if not add number: "cool-lounge-2"
3. Create business record
4. Create user (owner) record
5. Return JWT token + business_id

---

### Step 2: AI Personality Questionnaire

**Purpose**: Create a unique AI personality that matches the business vibe

**UI**: Multi-step wizard (6 steps)

#### Step 2.1: Basic Business Vibe

```javascript
{
  // Question: "How would you describe your business atmosphere?"
  business_atmosphere: "casual" | "upscale" | "lively" | "intimate" | "family_friendly",
  
  // Question: "Who is your primary target audience?"
  target_audience: "young professionals, students", // Free text
  
  // Question: "What's your typical price range?"
  price_range: "budget" | "moderate" | "premium" | "luxury"
}
```

**UI Example**:
```
┌─────────────────────────────────────────┐
│  Tell us about your business vibe      │
├─────────────────────────────────────────┤
│                                         │
│  How would you describe your           │
│  business atmosphere?                   │
│                                         │
│  [Casual] [Upscale] [Lively]          │
│  [Intimate] [Family Friendly]          │
│                                         │
│  Who's your target audience?           │
│  ┌─────────────────────────────────┐  │
│  │ young professionals, families    │  │
│  └─────────────────────────────────┘  │
│                                         │
│           [Next →]                      │
└─────────────────────────────────────────┘
```

#### Step 2.2: AI Personality Basics

```javascript
{
  // Question: "What should we call your AI assistant?"
  preferred_ai_name: "Alex", // Default based on business type
  
  // Question: "Choose your AI's voice/persona"
  ai_gender: "male" | "female" | "neutral",
  
  // Question: "How should your AI communicate?"
  personality_type: "friendly" | "professional" | "casual" | "energetic" | "sophisticated" | "humorous"
}
```

**UI Example with Preview**:
```
┌─────────────────────────────────────────┐
│  Name your AI Assistant                 │
├─────────────────────────────────────────┤
│                                         │
│  What should we call your assistant?   │
│  ┌─────────────────────────────────┐  │
│  │ Alex                             │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Choose personality type:               │
│  ○ Friendly & Welcoming                │
│  ● Professional & Helpful  ← Selected  │
│  ○ Casual & Fun                        │
│  ○ Energetic & Enthusiastic           │
│                                         │
│  ┌───────────────────────────────┐    │
│  │ Preview:                       │    │
│  │ "Good evening! I'm Alex,      │    │
│  │  your virtual assistant at     │    │
│  │  Cool Lounge. How may I       │    │
│  │  assist you today?"           │    │
│  └───────────────────────────────┘    │
│                                         │
│      [← Back]       [Next →]           │
└─────────────────────────────────────────┘
```

#### Step 2.3: Communication Style Sliders

```javascript
{
  // Scale 1-10 for each trait
  friendliness_level: 8,      // 1=Reserved, 10=Very Warm
  formality_level: 5,         // 1=Very Casual, 10=Very Formal  
  humor_level: 6,             // 1=Serious, 10=Funny
  chattiness_level: 7,        // 1=Brief, 10=Conversational
  
  // Additional options
  use_emojis: true,           // Use emojis in responses?
  use_local_slang: false,     // Use local expressions?
  response_length: "moderate" // concise, moderate, detailed
}
```

**UI Example**:
```
┌─────────────────────────────────────────┐
│  Fine-tune your AI's personality        │
├─────────────────────────────────────────┤
│                                         │
│  Friendliness Level                     │
│  Reserved ━━━━━━●━━━ Very Warm         │
│            1  2  3  4  5  6  7  8  9 10│
│                      ↑ (8)             │
│                                         │
│  Formality Level                        │
│  Casual ━━━●━━━━━━━ Very Formal        │
│          1  2  3  4  5  6  7  8  9 10  │
│                  ↑ (5)                 │
│                                         │
│  Humor Level                            │
│  Serious ━━━━━●━━━━ Very Funny         │
│           1  2  3  4  5  6  7  8  9 10 │
│                    ↑ (6)               │
│                                         │
│  ☑ Use emojis in responses             │
│  ☐ Use local slang/expressions         │
│                                         │
│      [← Back]       [Next →]           │
└─────────────────────────────────────────┘
```

#### Step 2.4: Business Specialties

```javascript
{
  // Question: "What makes your business special?"
  signature_items: [
    "Famous signature cocktails",
    "Live DJ every weekend",
    "Rooftop seating with city view"
  ],
  
  // Question: "What are your top 3 menu items?"
  house_specialties: [
    "Grilled Chicken Wings",
    "Mojito Supreme", 
    "BBQ Ribs"
  ],
  
  // Question: "Any customer favorites we should highlight?"
  customer_favorites: "Our happy hour specials and karaoke nights"
}
```

**UI Example**:
```
┌─────────────────────────────────────────┐
│  Tell us what makes you special         │
├─────────────────────────────────────────┤
│                                         │
│  What are your signature offerings?     │
│  ┌─────────────────────────────────┐  │
│  │ + Famous cocktails               │  │
│  │ + Live music every Friday        │  │
│  │ + Rooftop with city view         │  │
│  └─────────────────────────────────┘  │
│  [+ Add another]                       │
│                                         │
│  Top menu items customers love:         │
│  1. ┌───────────────────────────┐     │
│     │ Grilled Chicken Wings     │     │
│     └───────────────────────────┘     │
│  2. ┌───────────────────────────┐     │
│     │ Mojito Supreme            │     │
│     └───────────────────────────┘     │
│  3. ┌───────────────────────────┐     │
│     │ BBQ Ribs                  │     │
│     └───────────────────────────┘     │
│                                         │
│      [← Back]       [Next →]           │
└─────────────────────────────────────────┘
```

#### Step 2.5: House Rules & Policies

```javascript
{
  // Question: "Do you have a dress code?"
  dress_code: "Smart casual - no flip flops",
  
  // Question: "Any age restrictions?"
  age_restrictions: "18+ only after 9 PM",
  
  // Question: "Any special policies customers should know?"
  special_policies: "No outside food or drinks. Reservations required for groups of 6+"
}
```

#### Step 2.6: Business Goals & AI Behavior

```javascript
{
  // Question: "What's your primary goal with AGM BAR?"
  primary_goal: "increase_sales" | "improve_service" | "engage_customers" | "all",
  
  // Question: "How should your AI handle upselling?"
  upsell_strategy: "passive" | "moderate" | "aggressive",
  // passive: Only suggest when asked
  // moderate: Occasionally recommend complementary items
  // aggressive: Actively promote specials and premium items
  
  // Question: "Service speed preference?"
  service_speed: "quick" | "standard" | "relaxed",
  
  // Question: "Interaction preference?"
  interaction_preference: "minimal" | "helpful" | "conversational" | "entertaining",
  
  // Question: "Any final instructions for your AI?"
  additional_instructions: "Always mention our daily specials. Be extra friendly to first-time visitors."
}
```

**UI Example**:
```
┌─────────────────────────────────────────┐
│  How should your AI assist customers?   │
├─────────────────────────────────────────┤
│                                         │
│  Primary Goal:                          │
│  ○ Increase Sales                      │
│  ● Improve Customer Service            │
│  ○ Engage & Entertain                  │
│  ○ All of the above                    │
│                                         │
│  Upselling Approach:                    │
│  ○ Passive (only when asked)           │
│  ● Moderate (gentle suggestions)        │
│  ○ Aggressive (active promotion)       │
│                                         │
│  Additional instructions for your AI:   │
│  ┌─────────────────────────────────┐  │
│  │ Always mention our daily         │  │
│  │ specials. Be extra friendly to   │  │
│  │ first-time visitors.             │  │
│  └─────────────────────────────────┘  │
│                                         │
│      [← Back]    [Complete Setup]      │
└─────────────────────────────────────────┘
```

---

### Step 3: AI Personality Generation

**Backend Process** (after questionnaire submission):

```python
def generate_ai_personality(questionnaire_data):
    """
    Process questionnaire and create AI personality configuration
    """
    
    # Base prompt template based on personality type
    personality_templates = {
        "friendly": {
            "base_prompt": "You are {ai_name}, a warm and welcoming virtual assistant...",
            "greeting_suffix": "What can I help you with today? 😊"
        },
        "professional": {
            "base_prompt": "You are {ai_name}, a professional and efficient assistant...",
            "greeting_suffix": "How may I assist you?"
        },
        # ... more templates
    }
    
    # Construct greeting message
    greeting = f"Hello! I'm {ai_name}, your virtual assistant at {business_name}. {template.greeting_suffix}"
    
    # Build custom instructions
    custom_instructions = f"""
    BUSINESS CONTEXT:
    - Name: {business_name}
    - Type: {business_type}
    - Atmosphere: {business_atmosphere}
    - Target Audience: {target_audience}
    - Price Range: {price_range}
    
    PERSONALITY:
    - Name: {ai_name}
    - Type: {personality_type}
    - Friendliness: {friendliness_level}/10
    - Formality: {formality_level}/10
    - Humor: {humor_level}/10
    - Use Emojis: {use_emojis}
    
    WHAT MAKES US SPECIAL:
    {format_list(signature_items)}
    
    TOP MENU ITEMS TO RECOMMEND:
    {format_list(house_specialties)}
    
    HOUSE RULES:
    - Dress Code: {dress_code}
    - Age Restrictions: {age_restrictions}
    - Policies: {special_policies}
    
    BEHAVIOR GUIDELINES:
    - Service Speed: {service_speed}
    - Upselling: {upsell_strategy}
    - Interaction Style: {interaction_preference}
    
    ADDITIONAL INSTRUCTIONS:
    {additional_instructions}
    
    Remember: Always be {personality_adjectives}. Your goal is to {primary_goal}.
    """
    
    return {
        "greeting_message": greeting,
        "system_prompt": custom_instructions,
        "personality_config": {...}
    }
```

**Save to Database**:
```sql
INSERT INTO ai_personalities (
    business_id, personality_name, personality_type,
    greeting_message, custom_instructions, ...
) VALUES (...);

INSERT INTO onboarding_questionnaires (
    business_id, business_atmosphere, target_audience,
    raw_responses, ...
) VALUES (...);
```

---

### Step 4: Business Settings Configuration

**Endpoint**: `POST /api/v1/business/{business_id}/settings`

**Form Fields**:
```javascript
{
  // Operating Hours
  operating_hours: {
    monday: { open: "09:00", close: "23:00", closed: false },
    tuesday: { open: "09:00", close: "23:00", closed: false },
    // ... rest of week
  },
  
  // Features to enable
  enable_ai_chat: true,
  enable_ordering: true,
  enable_reservations: true,
  enable_games: true,
  
  // Notification channels
  whatsapp_enabled: true,
  whatsapp_number: "+2348012345678",
  
  telegram_enabled: false,
  
  // Table management
  total_tables: 15,
  table_prefix: "T"
}
```

---

### Step 5: QR Code Generation

**Endpoint**: `POST /api/v1/business/{business_id}/qr-codes`

**Backend Process**:
1. Generate main QR code pointing to: `https://{subdomain}.agmbar.com`
2. Optionally generate per-table QR codes: `https://{subdomain}.agmbar.com?table=5`
3. Save QR code URLs to database
4. Return downloadable QR codes

**Response**:
```javascript
{
  main_qr_code: "https://storage.agmbar.com/qr/coollounge-main.png",
  table_qr_codes: [
    { table: "T1", url: "https://storage.agmbar.com/qr/coollounge-t1.png" },
    { table: "T2", url: "https://storage.agmbar.com/qr/coollounge-t2.png" },
    // ... more tables
  ]
}
```

---

### Step 6: Onboarding Complete!

**Final Screen**:
```
┌─────────────────────────────────────────┐
│  🎉 Welcome to AGM BAR!                 │
├─────────────────────────────────────────┤
│                                         │
│  Your business is now live at:          │
│  https://coollounge.agmbar.com         │
│                                         │
│  Your AI assistant "Alex" is ready!     │
│                                         │
│  Next Steps:                            │
│  ✓ Add your menu items                 │
│  ✓ Download your QR codes              │
│  ✓ Test your AI assistant              │
│  ✓ Share your link                     │
│                                         │
│     [Go to Dashboard]  [Test AI]       │
└─────────────────────────────────────────┘
```

---

## Implementation Examples

### Frontend - Onboarding Wizard Component

```jsx
// components/onboarding/OnboardingWizard.jsx
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { onboardingService } from '@/services/onboardingService'
import toast from 'react-hot-toast'

const STEPS = [
  { id: 1, title: 'Business Vibe', component: BusinessVibeStep },
  { id: 2, title: 'AI Personality', component: AIPersonalityStep },
  { id: 3, title: 'Communication Style', component: CommunicationStyleStep },
  { id: 4, title: 'Specialties', component: SpecialtiesStep },
  { id: 5, title: 'House Rules', component: HouseRulesStep },
  { id: 6, title: 'Goals & Behavior', component: GoalsBehaviorStep },
]

export default function OnboardingWizard({ businessId }) {
  const [currentStep, setCurrentStep] = useState(1)
  const [formData, setFormData] = useState({})
  const navigate = useNavigate()

  const updateFormData = (stepData) => {
    setFormData(prev => ({ ...prev, ...stepData }))
  }

  const handleNext = () => {
    if (currentStep < STEPS.length) {
      setCurrentStep(prev => prev + 1)
    }
  }

  const handleBack = () => {
    if (currentStep > 1) {
      setCurrentStep(prev => prev - 1)
    }
  }

  const handleComplete = async () => {
    try {
      await onboardingService.submitQuestionnaire(businessId, formData)
      toast.success('Onboarding complete! 🎉')
      navigate('/admin/dashboard')
    } catch (error) {
      toast.error('Failed to complete onboarding')
    }
  }

  const CurrentStepComponent = STEPS[currentStep - 1].component

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-3xl mx-auto px-4">
        {/* Progress Bar */}
        <div className="mb-8">
          <div className="flex justify-between mb-2">
            {STEPS.map((step) => (
              <div
                key={step.id}
                className={`flex-1 text-center ${
                  step.id === currentStep ? 'text-primary-600 font-semibold' : 'text-gray-400'
                }`}
              >
                {step.title}
              </div>
            ))}
          </div>
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-primary-600 h-2 rounded-full transition-all duration-300"
              style={{ width: `${(currentStep / STEPS.length) * 100}%` }}
            />
          </div>
        </div>

        {/* Step Content */}
        <div className="bg-white rounded-lg shadow-md p-8">
          <CurrentStepComponent
            data={formData}
            onUpdate={updateFormData}
            onNext={handleNext}
            onBack={handleBack}
            onComplete={handleComplete}
            isFirst={currentStep === 1}
            isLast={currentStep === STEPS.length}
          />
        </div>
      </div>
    </div>
  )
}
```

### Backend - Onboarding Service

```python
# app/services/onboarding_service.py
from app.models import AIPersonality, OnboardingQuestionnaire
from app.core.database import get_db

class OnboardingService:
    
    def create_ai_personality(self, business_id: str, questionnaire_data: dict):
        """Generate AI personality from questionnaire responses"""
        
        # Generate greeting message
        greeting = self.generate_greeting(questionnaire_data)
        
        # Build custom instructions
        instructions = self.build_custom_instructions(questionnaire_data)
        
        # Create AI personality record
        personality = AIPersonality(
            business_id=business_id,
            personality_name=questionnaire_data.get('preferred_ai_name', 'Assistant'),
            personality_type=questionnaire_data['personality_type'],
            tone=self.determine_tone(questionnaire_data['formality_level']),
            greeting_message=greeting,
            custom_instructions=instructions,
            friendliness_level=questionnaire_data['friendliness_level'],
            formality_level=questionnaire_data['formality_level'],
            humor_level=questionnaire_data['humor_level'],
            chattiness_level=questionnaire_data['chattiness_level'],
            use_emojis=questionnaire_data.get('use_emojis', True),
            upsell_strategy=questionnaire_data['upsell_strategy'],
            # ... more fields
        )
        
        db = get_db()
        db.add(personality)
        db.commit()
        
        return personality
    
    def generate_greeting(self, data: dict) -> str:
        """Generate personalized greeting message"""
        ai_name = data.get('preferred_ai_name', 'Assistant')
        business_name = data.get('business_name')
        personality_type = data['personality_type']
        
        greetings = {
            'friendly': f"Hey there! 👋 Welcome to {business_name}! I'm {ai_name}, and I'm super excited to help you today!",
            'professional': f"Good day. I'm {ai_name}, your virtual assistant at {business_name}. How may I assist you?",
            'casual': f"What's up! I'm {ai_name} 😎 Here to help you out at {business_name}. What do you need?",
            'energetic': f"Hello Hello! 🎉 I'm {ai_name}! Welcome to {business_name}! Let's make your experience amazing!",
            'sophisticated': f"Welcome to {business_name}. I'm {ai_name}, your personal concierge. It's a pleasure to serve you.",
            'humorous': f"Hey hey! {ai_name} here, your friendly neighborhood AI at {business_name} 😄 Ready to make your day better!"
        }
        
        return greetings.get(personality_type, greetings['friendly'])
    
    def build_custom_instructions(self, data: dict) -> str:
        """Build comprehensive AI instructions from questionnaire"""
        # Implementation details...
        pass
```

---

## Testing the Onboarding

### Test Checklist

- [ ] Business registration creates subdomain
- [ ] Subdomain uniqueness validation works
- [ ] All questionnaire steps save properly
- [ ] AI personality is generated correctly
- [ ] Preview shows personalized AI responses
- [ ] QR codes are generated
- [ ] Business settings are saved
- [ ] User can access dashboard after onboarding
- [ ] AI responds with configured personality

---

## Subdomain Architecture

### DNS Configuration

```
*.agmbar.com → Your server IP
```

### Backend Subdomain Handling

```python
# app/middleware/subdomain.py
from fastapi import Request
from app.core.database import get_db
from app.models import Business

async def get_business_from_subdomain(request: Request):
    """Extract business from subdomain"""
    host = request.headers.get('host', '')
    subdomain = host.split('.')[0]
    
    if subdomain in ['www', 'api', 'admin']:
        return None
    
    db = get_db()
    business = db.query(Business).filter_by(
        subdomain=subdomain,
        is_active=True
    ).first()
    
    return business
```

### Frontend Routing

```jsx
// Handle subdomain-specific content
const subdomain = window.location.hostname.split('.')[0]

if (subdomain !== 'www' && subdomain !== 'admin') {
  // Customer-facing interface
  // Load business-specific theme and AI
} else {
  // Main site or admin dashboard
}
```

---

This comprehensive onboarding flow ensures each business gets a uniquely tailored AI assistant!
