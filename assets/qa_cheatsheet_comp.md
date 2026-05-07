# Fundamentals

## 1. Testing Types

### Functional Testing
| Type | Purpose | When to Use |
|------|---------|-------------|
| **Smoke** | Is the build testable? Core paths work? | After each new build deployment |
| **Sanity** | Is a specific bug fixed / feature working? | After a targeted fix or change |
| **Regression** | Did new changes break existing features? | Before every release |
| **Functional** | Does the feature work per requirements? | Throughout development |
| **UAT** | Does it meet business / user requirements? | Pre-release with stakeholders |
| **Exploratory** | Free-form discovery of unknown issues | When specs are unclear or new features land |
| **Ad-hoc** | Unplanned, intuition-driven testing | Supplement to formal test cases |

### Non-Functional Testing
| Type | Purpose |
|------|---------|
| **Performance** | Speed, responsiveness, stability under load |
| **Load** | Behavior under expected normal load |
| **Stress** | Beyond max capacity — find breaking point |
| **Security** | Vulnerabilities, auth flaws, data exposure |
| **Usability** | How easy and intuitive the app is to use |
| **Compatibility** | Works across OS, browsers, devices |
| **Reliability** | Consistent behavior over repeated runs |

### Structural Testing
| Type | Purpose |
|------|---------|
| **Unit** | Individual functions/components (developer-led) |
| **Integration** | Interaction between modules or services |
| **End-to-End (E2E)** | Full user journey from start to finish |
| **Contract** | API consumer/provider agreements are honored |
| **Component** | UI components in isolation |

### Quick Rule of Thumb
- **Smoke** → "Can we even test today?"
- **Sanity** → "Is this one thing fixed?"
- **Regression** → "Did we break anything else?"
- **Exploratory** → "What did we miss?"


## 2. Bug Report Template

### Standard Fields

```
Title:           [Module/Feature] Short, clear description of the defect
Bug ID:          BUG-001 (auto-assigned by tool)
Reporter:        Your Name
Date:            YYYY-MM-DD
Environment:     OS: Windows 11 | Browser: Chrome 124 | App Version: 2.3.1
                 Server: Staging | DB: v5.0.2
Severity:        Blocker / Critical / Major / Minor / Trivial
Priority:        High / Medium / Low
Status:          New / Open / In Progress / Fixed / Verified / Closed / Reopen

Preconditions:   - User is logged in as 'admin'
                 - At least 1 item in the cart

Steps to Reproduce:
  1. Navigate to /checkout
  2. Click "Apply Coupon"
  3. Enter code "SAVE10"
  4. Click "Apply"

Expected Result: Discount of 10% is applied; total updates correctly

Actual Result:   Page crashes with 500 Internal Server Error

Reproducibility: Always / Intermittent (3/5 times) / Rarely
Attachments:     screenshot.png | error-log.txt | screen-recording.mp4
Linked To:       Story: US-142 | Related Bug: BUG-098
```

### Bug Title Formula
```
[Module] Verb + Object + Condition

Good: [Checkout] Coupon code throws 500 error when applied with empty cart
Bad:  Coupon broken
```

### Reproducibility Scale
| Label | Meaning |
|-------|---------|
| **Always** | 100% reproducible every time |
| **Often** | Occurs more than 50% of attempts |
| **Sometimes** | Occurs 20–50% of attempts |
| **Rarely** | Hard to reproduce, < 20% |
| **Unable to Reproduce** | Cannot recreate after multiple tries |


## 3. Severity & Priority Matrix

### Severity Levels
| Level | Color | Definition | Example |
|-------|-------|-----------|---------|
| **Blocker** | 🔴 | App crashes, cannot proceed, data loss | Login is completely broken |
| **Critical** | 🟠 | Core feature broken, no workaround | Payment fails every time |
| **Major** | 🟡 | Feature broken but workaround exists | Export fails, but copy-paste works |
| **Minor** | 🔵 | Feature partially works, low impact | Dropdown doesn't auto-close |
| **Trivial** | ⚪ | Cosmetic only, no functional impact | Button text slightly misaligned |

### Priority Levels
| Level | Definition |
|-------|-----------|
| **High** | Must fix before release, business-critical |
| **Medium** | Should fix in this sprint if possible |
| **Low** | Fix when time allows, no release blocker |

### Severity vs Priority Matrix
```
                    PRIORITY
              High        Low
         ┌───────────┬───────────┐
S  High  │ Fix NOW   │ Schedule  │
E        │ (Blocker) │ carefully │
V        ├───────────┼───────────┤
E  Low   │ Fix soon  │ Backlog   │
R        │ (visible) │ item      │
         └───────────┴───────────┘
```

### Classic Conflict Examples
| Scenario | Severity | Priority |
|----------|---------|---------|
| Login broken on IE6 (0.01% users) | High | Low |
| CEO name misspelled on homepage | Low | High |
| Data corruption in niche edge case | High | Medium |
| Wrong icon color on hover | Low | Low |


## 4. Test Case Structure

### Template
```
Test Case ID:     TC-001
Module:           User Authentication
Feature:          Login
Title:            Verify successful login with valid credentials
Type:             Positive / Functional
Priority:         High
Linked Story:     US-010

Preconditions:
  - User account exists with email: test@example.com
  - User is not currently logged in
  - Browser cookies cleared

Test Steps:
  Step 1: Navigate to https://app.example.com/login
  Step 2: Enter email "test@example.com" in the Email field
  Step 3: Enter password "ValidPass@123" in the Password field
  Step 4: Click the "Login" button

Expected Result:
  - User is redirected to /dashboard
  - Welcome message displays "Hello, Test User"
  - Session token is created and stored
  - Login timestamp is updated in the database

Actual Result:    [Fill during execution]
Status:           Pass / Fail / Blocked / N/A / Skipped
Tester:           [Name]
Date Executed:    YYYY-MM-DD
Notes/Defects:    BUG-042 (if applicable)
```

### Test Case Title Formula
```
Verify [expected outcome] when [condition/input/action]

Examples:
✅ Verify user is redirected to dashboard when valid credentials are entered
✅ Verify error message appears when password field is left empty
✅ Verify cart total updates when item quantity is changed
❌ Login test
❌ Check if submit works
```

### Test Case Types
| Type | What to Test |
|------|-------------|
| **Positive** | Valid inputs, happy path |
| **Negative** | Invalid inputs, error handling |
| **Boundary** | Edge values (min, max, just outside) |
| **UI** | Visual elements, layout, responsiveness |
| **Integration** | Module interactions |
| **Performance** | Speed, load, stability |


## 5. Testing Techniques

### Equivalence Partitioning (EP)
Divide input into groups where all values are expected to behave the same.

```
Age field (valid: 18–65):
  ┌─────────────┬────────────────┬──────────────┐
  │ Class       │ Values         │ Test Value   │
  ├─────────────┼────────────────┼──────────────┤
  │ Below range │ < 18           │ 10           │
  │ Valid range │ 18–65          │ 40           │
  │ Above range │ > 65           │ 80           │
  └─────────────┴────────────────┴──────────────┘
```

### Boundary Value Analysis (BVA)
Test at and just around the edges of valid ranges.

```
Password length (min: 8, max: 20):
  INVALID: 7 chars
  VALID:   8 chars   ← min boundary
  VALID:   9 chars   ← min + 1
  VALID:   19 chars  ← max - 1
  VALID:   20 chars  ← max boundary
  INVALID: 21 chars
```

### Decision Table Testing
Map combinations of conditions to expected actions.

```
| Condition A | Condition B | Condition C | Action     |
|-------------|-------------|-------------|------------|
| TRUE        | TRUE        | TRUE        | Result 1   |
| TRUE        | TRUE        | FALSE       | Result 2   |
| TRUE        | FALSE       | TRUE        | Result 3   |
| FALSE       | FALSE       | FALSE       | Result 4   |
```

### State Transition Testing
Test how the system moves between valid states.

```
States: Draft → Submitted → Approved → Published → Archived

Valid Transitions:
  Draft      → Submitted  (click Submit)
  Submitted  → Approved   (admin approves)
  Approved   → Published  (click Publish)
  Published  → Archived   (click Archive)

Invalid Transitions to test:
  Draft → Approved  (should be blocked)
  Archived → Published (should be blocked)
```

### Pairwise (All-Pairs) Testing
Cover all combinations of 2 variables — reduces test cases dramatically.

```
Variables: OS (Win/Mac/Linux), Browser (Chrome/Firefox), Role (Admin/User)
Instead of 12 combinations → test ~6 pairs that cover all 2-way combos
```

### Error Guessing
Use experience and intuition to find likely bugs:
- Submit empty forms
- Submit with only spaces
- Upload wrong file type
- Enter negative numbers where positive expected
- Very large numbers / very long strings
- Refresh mid-transaction
- Double-click submit buttons
- Copy-paste content with hidden characters


# Technical Skills

## 6. API Testing

### HTTP Methods
| Method | Purpose | Has Body | Idempotent |
|--------|---------|---------|-----------|
| **GET** | Retrieve resource | No | Yes |
| **POST** | Create new resource | Yes | No |
| **PUT** | Replace entire resource | Yes | Yes |
| **PATCH** | Partial update | Yes | No |
| **DELETE** | Remove resource | No | Yes |
| **HEAD** | GET without body (check headers) | No | Yes |
| **OPTIONS** | Check allowed methods | No | Yes |

### HTTP Status Codes
```
2xx — Success
  200 OK                  Standard success
  201 Created             Resource created (POST)
  204 No Content          Success but no body (DELETE)
  206 Partial Content     Range request

3xx — Redirection
  301 Moved Permanently   URL changed forever
  302 Found               Temporary redirect
  304 Not Modified        Cached version OK

4xx — Client Errors
  400 Bad Request         Malformed request / invalid input
  401 Unauthorized        Not authenticated (no/bad token)
  403 Forbidden           Authenticated but no permission
  404 Not Found           Resource doesn't exist
  405 Method Not Allowed  Wrong HTTP verb used
  409 Conflict            Resource already exists / state conflict
  422 Unprocessable       Validation failed
  429 Too Many Requests   Rate limit hit

5xx — Server Errors
  500 Internal Server Error   Something broke server-side
  502 Bad Gateway             Upstream server error
  503 Service Unavailable     Server down / overloaded
  504 Gateway Timeout         Upstream took too long
```

### API Test Checklist
- [ ] Correct HTTP status code returned
- [ ] Response body matches expected schema
- [ ] Required fields present in response
- [ ] Data types are correct (string, int, bool, null)
- [ ] Response time within acceptable threshold
- [ ] Headers correct (Content-Type, Authorization, CORS)
- [ ] Pagination works (page, limit, total)
- [ ] Sorting and filtering return correct results
- [ ] Auth token required on protected endpoints
- [ ] Invalid token returns 401
- [ ] Missing required fields return 400/422 with helpful message
- [ ] SQL injection / XSS in input fields → safe response
- [ ] Large payloads handled gracefully

### REST vs Common Patterns
```
Resource: /users

GET    /users          → list all users
POST   /users          → create new user
GET    /users/{id}     → get specific user
PUT    /users/{id}     → replace user
PATCH  /users/{id}     → update user fields
DELETE /users/{id}     → delete user

Nested: /users/{id}/orders
GET    /users/5/orders → orders for user 5
POST   /users/5/orders → create order for user 5
```

### Sample Postman Test Scripts
```javascript
// Status code check
pm.test("Status is 200", () => {
  pm.response.to.have.status(200);
});

// Response time check
pm.test("Response < 500ms", () => {
  pm.expect(pm.response.responseTime).to.be.below(500);
});

// Body field check
pm.test("User has ID", () => {
  const body = pm.response.json();
  pm.expect(body.id).to.be.a('number');
  pm.expect(body.email).to.include('@');
});

// Schema validation
pm.test("Schema is valid", () => {
  const schema = {
    type: "object",
    required: ["id", "email", "name"],
    properties: {
      id: { type: "number" },
      email: { type: "string" },
      name: { type: "string" }
    }
  };
  pm.response.to.have.jsonSchema(schema);
});
```


## 7. SQL for QA

### Basic Queries
```sql
-- Select all records
SELECT * FROM users;

-- Select specific columns
SELECT id, name, email FROM users;

-- Filter with WHERE
SELECT * FROM orders WHERE status = 'pending';

-- Multiple conditions
SELECT * FROM products 
WHERE price > 10 AND category = 'electronics' AND stock > 0;

-- Pattern matching
SELECT * FROM users WHERE email LIKE '%@gmail.com';

-- Null checks
SELECT * FROM users WHERE phone IS NULL;
SELECT * FROM users WHERE phone IS NOT NULL;

-- Order results
SELECT * FROM products ORDER BY price DESC;
SELECT * FROM products ORDER BY name ASC, price DESC;

-- Limit results
SELECT * FROM logs ORDER BY created_at DESC LIMIT 10;
```

### Aggregate Functions
```sql
-- Count records
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM orders WHERE status = 'completed';

-- Sum, average, min, max
SELECT 
  SUM(amount) AS total_revenue,
  AVG(amount) AS avg_order,
  MIN(amount) AS smallest,
  MAX(amount) AS largest
FROM orders;

-- Group by
SELECT status, COUNT(*) AS count 
FROM orders 
GROUP BY status;

-- Group by with filter
SELECT user_id, COUNT(*) AS order_count
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 5;
```

### Joins
```sql
-- INNER JOIN (only matching rows)
SELECT u.name, o.total, o.created_at
FROM users u
INNER JOIN orders o ON u.id = o.user_id;

-- LEFT JOIN (all users, even with no orders)
SELECT u.name, o.total
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- Multiple joins
SELECT u.name, p.name AS product, oi.quantity
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;
```

### Data Validation Queries
```sql
-- Find duplicates
SELECT email, COUNT(*) AS count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;

-- Find orphaned records (order without user)
SELECT o.* FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL;

-- Check data range
SELECT * FROM products WHERE price < 0 OR price > 99999;

-- Check for invalid email format (basic)
SELECT * FROM users WHERE email NOT LIKE '%@%.%';

-- Records modified in last 24 hours
SELECT * FROM users 
WHERE updated_at >= NOW() - INTERVAL 1 DAY;

-- Cross-check totals
SELECT 
  SUM(amount) AS invoice_total,
  (SELECT SUM(line_total) FROM order_items WHERE order_id = 5) AS items_total
FROM invoices WHERE order_id = 5;
```


## 8. Web Testing Checklist

### Functional
- [ ] All links work — no broken links (404)
- [ ] All buttons trigger correct actions
- [ ] Form submission works with valid data
- [ ] Form validation rejects invalid inputs
- [ ] Required fields enforced (empty submit blocked)
- [ ] File upload works (correct types, size limits enforced)
- [ ] Search returns relevant results
- [ ] Pagination, sorting, filtering works correctly
- [ ] CRUD operations work (Create, Read, Update, Delete)
- [ ] Email notifications triggered where expected

### UI / Visual
- [ ] UI consistent across all pages (fonts, colors, spacing)
- [ ] Images load correctly (no broken images)
- [ ] Correct copy/text (no typos, placeholder text removed)
- [ ] Responsive layout on desktop / tablet / mobile
- [ ] No horizontal scroll on any standard viewport
- [ ] Modals and dropdowns open/close correctly
- [ ] Loading states shown during async actions
- [ ] Success/error messages display correctly
- [ ] Tooltips render in correct positions

### Cross-Browser
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Chrome on Android
- [ ] Safari on iOS

### Security (Basic)
- [ ] HTTPS enforced (no HTTP)
- [ ] No mixed content warnings
- [ ] Sensitive data not visible in URL
- [ ] Auth tokens not exposed in localStorage when avoidable
- [ ] SQL injection attempts handled safely
- [ ] XSS: `<script>alert(1)</script>` in inputs — not executed
- [ ] Session invalidated after logout

### Performance
- [ ] Page load time < 3 seconds (LCP)
- [ ] No console errors in DevTools
- [ ] Images optimized and sized correctly
- [ ] No unnecessary large network requests

### Edge Cases
- [ ] Back button behavior is correct
- [ ] Refresh during form submission handled gracefully
- [ ] Double-click submit doesn't create duplicates
- [ ] Long text content doesn't break layout
- [ ] Special characters in inputs handled: `< > " ' ; & # @`
- [ ] Unicode and emoji in text fields work


## 9. Mobile Testing Checklist

### Devices & OS
- [ ] Small phones (320–375px): iPhone SE, Galaxy A series
- [ ] Standard phones (390–414px): iPhone 14, Pixel 7
- [ ] Large phones (428px+): iPhone 14 Pro Max
- [ ] Tablets (768px+): iPad, Galaxy Tab
- [ ] iOS latest version + 1 version back
- [ ] Android latest version + 1 version back

### Layout & Display
- [ ] Portrait and landscape orientation
- [ ] No horizontal scrolling
- [ ] Touch targets ≥ 44×44px (tappable areas large enough)
- [ ] Keyboard does not obscure input fields
- [ ] Content doesn't shift when keyboard appears
- [ ] Safe area insets respected (iPhone notch, dynamic island)

### Gestures
- [ ] Tap works correctly
- [ ] Long press (context menus, selection)
- [ ] Swipe left/right (carousels, navigation, delete actions)
- [ ] Pinch to zoom (where applicable)
- [ ] Pull to refresh
- [ ] Scroll performance is smooth (60fps)

### Network Conditions
- [ ] WiFi — normal behavior
- [ ] 4G/LTE — acceptable performance
- [ ] 3G — graceful degradation
- [ ] Offline — appropriate error shown, no crash
- [ ] Flaky network — retries or error state handled

### Interruptions
- [ ] Incoming call mid-flow
- [ ] SMS received
- [ ] Push notification tapped (deep link correct?)
- [ ] App backgrounded and foregrounded
- [ ] Screen lock / unlock mid-session

### Device-Specific
- [ ] Camera and gallery permissions
- [ ] Location permissions
- [ ] Notification permissions
- [ ] Biometric auth (Face ID, fingerprint) if applicable
- [ ] Low battery behavior (if relevant)
- [ ] Low storage behavior
- [ ] Dark mode / light mode rendering


## 10. Performance Testing

### Test Types
| Type | Description | Goal |
|------|-------------|------|
| **Load** | Expected normal traffic | Verify behavior under typical load |
| **Stress** | Beyond maximum capacity | Find the breaking point |
| **Spike** | Sudden huge traffic burst | Verify recovery from traffic surge |
| **Soak / Endurance** | Normal load for extended time | Find memory leaks, degradation |
| **Volume** | Large amounts of data in DB | DB performance at scale |
| **Scalability** | Gradually increasing load | Understand when to scale infra |

### Key Metrics
| Metric | Description | Target |
|--------|-------------|--------|
| **Response Time** | Time from request to first byte | < 200ms (API), < 3s (page) |
| **Throughput** | Requests per second (RPS) | Based on expected load |
| **Error Rate** | % of failed requests | < 1% under normal load |
| **Latency (P95/P99)** | 95th/99th percentile response time | P95 < 1s |
| **CPU Usage** | Server CPU during test | < 80% at peak |
| **Memory Usage** | RAM consumption over time | Stable, no leaks |
| **Concurrent Users** | Simultaneous active sessions | Meets product requirements |
| **Apdex Score** | User satisfaction index (0–1) | > 0.85 acceptable |

### Web Vitals (Frontend Performance)
| Metric | Full Name | Good Threshold |
|--------|-----------|---------------|
| **LCP** | Largest Contentful Paint | ≤ 2.5s |
| **FID** | First Input Delay | ≤ 100ms |
| **CLS** | Cumulative Layout Shift | ≤ 0.1 |
| **FCP** | First Contentful Paint | ≤ 1.8s |
| **TTFB** | Time to First Byte | ≤ 800ms |
| **TTI** | Time to Interactive | ≤ 3.8s |

### Tools
| Tool | Best For |
|------|---------|
| **k6** | Script-based, developer-friendly, CI integration |
| **JMeter** | GUI-based, widely used, extensive plugins |
| **Gatling** | Scala/Kotlin DSL, high performance reports |
| **Locust** | Python-based, easy to script |
| **Artillery** | YAML/JS, great for microservices |
| **Lighthouse** | Frontend performance (built into Chrome) |
| **WebPageTest** | Detailed waterfall + filmstrip analysis |


## 11. Accessibility (a11y)

### WCAG 2.1 Levels
| Level | Description | Target |
|-------|-------------|--------|
| **A** | Minimum baseline — must satisfy | Required |
| **AA** | Standard level — legal compliance in most regions | Target for most products |
| **AAA** | Enhanced — highest accessibility | Optional / aspirational |

### Core Checks
#### Visual
- [ ] Color contrast ratio ≥ 4.5:1 for normal text
- [ ] Color contrast ratio ≥ 3:1 for large text (18pt+) and UI components
- [ ] Not relying on color alone to convey meaning
- [ ] Text can scale to 200% without loss of content or function
- [ ] No content flashes more than 3 times per second

#### Images & Media
- [ ] All meaningful images have descriptive `alt` text
- [ ] Decorative images have `alt=""`
- [ ] Videos have captions
- [ ] Audio has transcripts

#### Keyboard Navigation
- [ ] All interactive elements reachable by `Tab` key
- [ ] Logical tab order (top→bottom, left→right)
- [ ] Focus indicator always visible
- [ ] No keyboard traps (can always tab out)
- [ ] Modals: focus moves into modal, returns on close
- [ ] Dropdowns navigable with arrow keys

#### Forms
- [ ] All inputs have associated `<label>` (via `for`/`id`)
- [ ] Required fields marked (not just by color)
- [ ] Error messages descriptive and linked to field
- [ ] Autocomplete attributes set (`autocomplete="email"` etc.)

#### Semantic HTML
- [ ] Correct heading hierarchy (h1 → h2 → h3, never skip)
- [ ] Landmark elements used: `<header>`, `<nav>`, `<main>`, `<footer>`
- [ ] Buttons are `<button>`, links are `<a href>`
- [ ] Lists use `<ul>` / `<ol>` / `<li>`
- [ ] Tables have `<th>` with `scope` attribute

#### Screen Reader
- [ ] ARIA labels on icon-only buttons
- [ ] Live regions (`aria-live`) for dynamic content updates
- [ ] Page `<title>` is descriptive and unique
- [ ] Skip navigation link at top of page

### Testing Tools
| Tool | Type |
|------|------|
| **axe DevTools** | Browser extension — automated scan |
| **WAVE** | Visual overlay showing a11y issues |
| **Lighthouse** | Chrome built-in — a11y audit score |
| **NVDA** | Free screen reader (Windows) |
| **VoiceOver** | Built-in screen reader (Mac/iOS) |
| **TalkBack** | Android screen reader |
| **Color Contrast Analyzer** | Desktop tool — check contrast ratios |


# Strategy & Tools

## 12. Automation Concepts

### Test Pyramid
```
         /‾‾‾‾‾‾‾‾‾\
        /    E2E     \       ← Few, slow, expensive
       /  (Cypress,   \
      /   Playwright)  \
     /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
    /   Integration      \   ← Some, medium cost
   / (API, DB, services) \
  /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
 /        Unit Tests       \  ← Many, fast, cheap
/  (Jest, Pytest, JUnit)    \
```

### Page Object Model (POM)
```javascript
// LoginPage.js — store selectors and actions here
class LoginPage {
  constructor(page) {
    this.page = page;
    this.emailInput = page.locator('#email');
    this.passwordInput = page.locator('#password');
    this.loginButton = page.locator('button[type="submit"]');
    this.errorMessage = page.locator('.error-banner');
  }

  async login(email, password) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }

  async getErrorText() {
    return this.errorMessage.textContent();
  }
}

// login.test.js — use POM in tests
test('valid login redirects to dashboard', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.login('user@test.com', 'Password123');
  await expect(page).toHaveURL('/dashboard');
});
```

### AAA Test Pattern
```javascript
test('cart total updates when quantity changes', async () => {
  // ARRANGE — set up the conditions
  await cart.addItem({ id: 1, price: 10, qty: 2 });

  // ACT — perform the action
  await cart.updateQuantity(1, 3);

  // ASSERT — verify the outcome
  expect(await cart.getTotal()).toBe(30);
});
```

### Flaky Test Fixes
| Problem | Solution |
|---------|---------|
| Random timing failures | Use `waitFor` / explicit waits, never `sleep()` |
| Shared test data | Isolate data per test, use factories/fixtures |
| Environment dependency | Mock external calls, use test containers |
| Order-dependent tests | Each test must be fully independent |
| Network instability | Mock or stub network in unit/integration tests |
| Race conditions | Add proper assertions before interactions |

### CI/CD Integration
```yaml
# Example: GitHub Actions
name: Run Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: npm install
      - name: Run unit tests
        run: npm run test:unit
      - name: Run E2E tests
        run: npm run test:e2e
      - name: Upload test report
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: test-results/
```

### Framework Quick Reference
| Framework | Language | Best For |
|-----------|---------|---------|
| **Playwright** | JS/TS/Python/Java | Modern E2E, multi-browser |
| **Cypress** | JS/TS | Frontend E2E, great DX |
| **Selenium** | Multi | Legacy, broad compatibility |
| **WebdriverIO** | JS/TS | Flexible, Appium integration |
| **Jest** | JS/TS | Unit + integration (React) |
| **Pytest** | Python | Backend, API, flexible |
| **JUnit** | Java | Java backend unit tests |
| **RestAssured** | Java | API testing (Java) |
| **Appium** | Multi | Mobile automation (iOS/Android) |
| **k6** | JS | Performance / load testing |


## 13. Agile QA Terms & Concepts

### Core Terms
| Term | Definition |
|------|-----------|
| **Sprint** | Time-boxed iteration (1–4 weeks) |
| **Backlog** | Prioritized list of all work |
| **User Story** | "As a [user], I want [goal] so that [reason]" |
| **Acceptance Criteria** | Conditions a story must satisfy to be done |
| **DoD (Definition of Done)** | All exit criteria that must be met to close work |
| **DoR (Definition of Ready)** | Criteria for a story to be sprint-eligible |
| **Velocity** | Average story points completed per sprint |
| **Story Points** | Relative effort estimate (Fibonacci: 1,2,3,5,8,13,21) |
| **Spike** | Research task with a timebox — no deliverable |
| **Technical Debt** | Shortcuts taken now that must be fixed later |
| **Shift-Left Testing** | Test earlier in the cycle to catch bugs sooner |

### QA Activities Per Sprint Phase
```
SPRINT PLANNING
  ├── Review user stories for testability
  ├── Clarify acceptance criteria (ask "what if...?")
  ├── Identify test dependencies and risks
  └── Estimate testing effort

DEVELOPMENT (Mid-Sprint)
  ├── Write test cases as dev progresses
  ├── API / integration testing as features land
  ├── Exploratory testing on completed features
  └── Raise bugs early (shift-left)

END OF SPRINT
  ├── Full regression on sprint features
  ├── Verify all AC met
  ├── Sign off stories for demo
  └── Update test cases / automate new cases

RELEASE
  └── Smoke test on production post-deploy
```

### Good Acceptance Criteria (SMART)
```
Bad AC:  "Login should work"

Good AC:
  ✅ Given a user with valid credentials exists
     When they enter correct email and password
     Then they are redirected to /dashboard within 2 seconds
     And a session cookie is set
     And login timestamp is updated in the database
```

### Given / When / Then (BDD Gherkin)
```gherkin
Feature: User Login

  Scenario: Successful login with valid credentials
    Given I am on the login page
    And a user exists with email "user@test.com" and password "Pass123!"
    When I enter "user@test.com" in the email field
    And I enter "Pass123!" in the password field
    And I click "Login"
    Then I should be redirected to "/dashboard"
    And I should see "Welcome, User" on the page

  Scenario: Failed login with wrong password
    Given I am on the login page
    When I enter "user@test.com" in the email field
    And I enter "WrongPass" in the password field
    And I click "Login"
    Then I should see "Invalid email or password"
    And I should remain on the login page
```


## 14. DevTools & Tool Shortcuts

### Chrome DevTools
| Action | Shortcut |
|--------|---------|
| Open DevTools | `F12` or `Ctrl+Shift+I` (Win) / `Cmd+Option+I` (Mac) |
| Inspect element | `Ctrl+Shift+C` / `Cmd+Shift+C` |
| Open Console | `Ctrl+Shift+J` / `Cmd+Option+J` |
| Toggle device mode | `Ctrl+Shift+M` / `Cmd+Shift+M` |
| Hard reload (clear cache) | `Ctrl+Shift+R` / `Cmd+Shift+R` |
| Search in DevTools | `Ctrl+F` within panel |
| Open Network tab | `Ctrl+Shift+E` |
| Clear console | `Ctrl+L` |

### Browser Console Useful Commands
```javascript
// Check local/session storage
localStorage.getItem('token');
sessionStorage.clear();

// Intercept network (DevTools Console)
window.fetch = new Proxy(window.fetch, {
  apply: (target, thisArg, args) => {
    console.log('Fetch:', args[0]);
    return target.apply(thisArg, args);
  }
});

// Simulate slow network (via DevTools Network tab)
// Throttle: Fast 3G / Slow 3G / Offline
```

### Postman Shortcuts
| Action | Shortcut |
|--------|---------|
| Send request | `Ctrl+Enter` |
| New request | `Ctrl+T` |
| New tab | `Ctrl+T` |
| Save request | `Ctrl+S` |
| Open console | `Ctrl+Alt+C` |
| Format body JSON | `Ctrl+B` |
| Toggle sidebar | `Ctrl+\` |

### VS Code (for automation)
| Action | Shortcut |
|--------|---------|
| Run current test | `Ctrl+Shift+P` → "Run Test" |
| Open terminal | `Ctrl+`` ` |
| Find in all files | `Ctrl+Shift+F` |
| Go to definition | `F12` |
| Rename symbol | `F2` |
| Multi-cursor | `Alt+Click` |

### Jira / TestRail Quick Reference
| Action | Jira | TestRail |
|--------|------|---------|
| New bug | `C` (create) | Add Defect |
| Quick search | `/` | `Ctrl+F` |
| Assign | Use assignee field | Assign To |
| Add comment | `M` | Comments tab |


## 15. QA Mindset & Heuristics

### SFDPOT (San Francisco Depot)
| Letter | Category | Ask Yourself |
|--------|---------|-------------|
| **S** | Structure | How is it built? Any architectural risks? |
| **F** | Function | What does it do? Does it do it correctly? |
| **D** | Data | What goes in? What comes out? Data integrity? |
| **P** | Platform | OS, browser, device, environment dependencies? |
| **O** | Operations | How is it used in practice? Common workflows? |
| **T** | Time | Timing, sequences, concurrency, timeouts? |

### CRUD Testing Matrix
For any feature dealing with data, always test:
```
CREATE: Does it create correctly? Duplicates? Required fields?
READ:   Does it display accurately? Permissions correct?
UPDATE: Does it save correctly? Partial updates? Concurrent edits?
DELETE: Does it delete the right record? Cascade effects? Soft vs hard delete?
```

### Classic Edge Cases — Always Try
```
Input Edge Cases:
  □ Empty / blank / whitespace-only
  □ Single character
  □ Maximum length + 1 character
  □ Numbers in text fields, text in number fields
  □ Negative numbers, zero, decimal values
  □ Special characters: < > " ' ; & # @ % $ ! =
  □ SQL injection: ' OR '1'='1'; DROP TABLE users; --
  □ XSS: <script>alert('xss')</script>
  □ Unicode: 日本語, العربية, emoji 🎉🔥
  □ Very large numbers: 9999999999999
  □ Scientific notation: 1e10

State Edge Cases:
  □ Expired session — what happens?
  □ Simultaneous logins (same account, 2 devices)
  □ Concurrent modifications (two users editing same record)
  □ Mid-process interruption (close tab, kill power)
  □ Browser back after submitting
  □ Double-submit (click button twice rapidly)
  □ Paste content with hidden characters / newlines

System Edge Cases:
  □ Midnight / end-of-month / leap year / DST change
  □ Timezone changes (server vs user vs stored data)
  □ Database at capacity
  □ File system permissions
  □ Third-party service down (payment, email, maps)
```

### Test Coverage Mindset
```
For every feature, ask:
  1. What's the happy path? (test it first)
  2. What are the error paths? (invalid input, missing data)
  3. What are the edge cases? (extremes, boundaries)
  4. What are the security concerns? (auth, injection)
  5. What are the performance concerns? (load, volume)
  6. What breaks if this interacts with other features?
  7. What does this look like on mobile?
  8. What happens when the network is slow or down?
```


## 16. Security Testing Basics

### OWASP Top 10 (Brief)
| # | Vulnerability | Quick Test |
|---|--------------|-----------|
| 1 | **Broken Access Control** | Access another user's data by changing IDs in URL |
| 2 | **Cryptographic Failures** | Is sensitive data transmitted over HTTP? Stored in plaintext? |
| 3 | **Injection** | SQL/XSS/command injection in input fields |
| 4 | **Insecure Design** | Logic flaws, missing rate limiting |
| 5 | **Security Misconfiguration** | Default creds, exposed error messages, open ports |
| 6 | **Vulnerable Components** | Outdated libraries with known CVEs |
| 7 | **Auth Failures** | Weak passwords allowed, no MFA, session not invalidated |
| 8 | **Data Integrity Failures** | Unsigned JWTs accepted, insecure deserialization |
| 9 | **Logging Failures** | No logs on auth failures, sensitive data in logs |
| 10 | **SSRF** | Server fetches arbitrary URLs from user input |

### Quick Security Checks for QA
```
Authentication:
  □ Cannot login with blank password
  □ Account locked after N failed attempts
  □ Password reset link expires after use / time
  □ Session token invalidated on logout
  □ JWT not accepted if tampered

Authorization:
  □ User A cannot access User B's data (IDOR)
  □ Non-admin cannot access /admin routes
  □ Changing role in token doesn't elevate privileges

Data:
  □ Passwords stored as hashed (not in GET params)
  □ Credit card / SSN masked in UI and logs
  □ Sensitive data not in URL (use body/headers)
  □ HTTPS enforced, no mixed content

Input:
  □ XSS: <script>alert(1)</script> in all text fields
  □ SQL injection: ' OR 1=1--
  □ File upload: .php, .exe, .sh files rejected
  □ File upload: max size enforced
```


## 17. Test Metrics & Reporting

### Key Metrics to Track
| Metric | Formula | Target |
|--------|---------|--------|
| **Test Pass Rate** | (Passed / Total) × 100 | > 95% at release |
| **Defect Detection Rate** | Bugs found in test / total bugs | > 90% pre-release |
| **Defect Escape Rate** | Prod bugs / total bugs | < 5% |
| **Test Coverage** | Test cases / requirements | 100% of critical paths |
| **Bug Density** | Bugs / feature or KLOC | Track trend over time |
| **Mean Time to Fix (MTTF)** | Total fix time / # bugs fixed | Decreasing trend |
| **Blocked Test Rate** | Blocked / Total tests | < 5% |
| **Automation Coverage** | Automated / Total test cases | > 70% for regression |

### Test Summary Report Structure
```
TEST SUMMARY REPORT
Sprint/Release: Sprint 24 | v2.3.0
Period: 2025-01-13 to 2025-01-24
Tester: [Name]

EXECUTION SUMMARY
  Total Test Cases:    150
  Executed:            148
  Passed:              141 (95.3%)
  Failed:              7   (4.7%)
  Blocked:             2
  Not Executed:        2

DEFECT SUMMARY
  Total Bugs Raised:   12
  Blocker:             1
  Critical:            2
  Major:               4
  Minor:               5
  Fixed & Verified:    9
  Open:                3

RISK & SIGN-OFF
  Risk:    3 open bugs (1 minor, 2 trivial — accepted by PO)
  Decision: GO / NO-GO
  Sign-off: [QA Lead] [PO] [Dev Lead]
```


## 18. Common Tools Reference

### Test Management
| Tool | Best For |
|------|---------|
| **TestRail** | Comprehensive test case management |
| **Zephyr (Jira)** | Jira-integrated test management |
| **Xray (Jira)** | BDD + manual + automated in Jira |
| **qTest** | Enterprise test management |
| **Notion / Confluence** | Lightweight, document-based |

### Bug Tracking
| Tool | Notes |
|------|-------|
| **Jira** | Industry standard, highly customizable |
| **Linear** | Modern, fast, developer-friendly |
| **GitHub Issues** | Great for dev-focused teams |
| **Trello** | Simple kanban for small teams |
| **Bugzilla** | Open source, legacy but stable |

### API Testing
| Tool | Notes |
|------|-------|
| **Postman** | Most popular, great for manual + scripted |
| **Insomnia** | Clean UI, good for REST + GraphQL |
| **Bruno** | Open source, git-friendly |
| **curl** | CLI-based, scriptable |
| **Hoppscotch** | Browser-based, open source |

### Automation (E2E)
| Tool | Language | Notes |
|------|---------|-------|
| **Playwright** | JS/TS/Python/Java | Best modern choice, multi-browser |
| **Cypress** | JS/TS | Great DX, strong community |
| **Selenium** | Multi | Widest compatibility, older APIs |
| **WebdriverIO** | JS/TS | Flexible, supports Appium |

### Performance
| Tool | Use Case |
|------|---------|
| **k6** | Code-based load testing, CI-friendly |
| **JMeter** | GUI-based, widely used |
| **Locust** | Python-based, easy to write |
| **Lighthouse** | Frontend performance auditing |
| **Artillery** | YAML-based, microservices |

### Monitoring & Observability
| Tool | Use Case |
|------|---------|
| **Sentry** | Error tracking and alerts |
| **Datadog** | Full-stack monitoring |
| **Grafana + Prometheus** | Metrics dashboards |
| **Splunk** | Log analysis |
| **New Relic** | APM and infrastructure monitoring |


*QA Cheat Sheet Compilation — Keep updated as your stack evolves.*
