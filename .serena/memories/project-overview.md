# Spliit - Project Overview

## Descrizione
Spliit è un'alternativa open source a Splitwise per gestire spese condivise tra gruppi di persone.

## Stack Tecnologico
- **Framework**: Next.js 16 (App Router) + React 19
- **Linguaggio**: TypeScript
- **Database**: PostgreSQL con Prisma ORM
- **UI**: TailwindCSS + shadcn/UI + Radix UI
- **State Management**: tRPC + TanStack Query
- **Internazionalizzazione**: next-intl
- **Hosting**: Vercel (opzionale); istanza personale su NAS Synology (vedi memoria `deploy-nas`)

## Struttura Database (Prisma)
- **Group**: gruppi di spesa con partecipanti
- **Participant**: membri di un gruppo
- **Expense**: spese con split configurabile (EVENLY, BY_SHARES, BY_PERCENTAGE, BY_AMOUNT)
- **ExpensePaidFor**: relazione many-to-many tra spese e partecipanti
- **Category**: categorie per le spese
- **Activity**: log delle attività
- **RecurringExpenseLink**: gestione spese ricorrenti (`RecurrenceRule`: NONE, DAILY, WEEKLY, MONTHLY)
- **ExpenseDocument**: allegati immagini alle spese

## Feature Principali
- Creazione gruppi e spese
- Split spese (equo, per quote, percentuale, importo)
- Calcolo bilanci e rimborsi
- Upload documenti (S3)
- Scansione ricevute (OpenAI o provider compatibile, default `gpt-5-nano`)
- Deduzione automatica categoria (OpenAI)
- PWA
- Export CSV/JSON
- Statistiche gruppo
- Analytics anonime opzionali (`ANALYTICS_PROVIDER`: console, plausible, umami; codice in `src/lib/analytics/`)

## Variabili Ambiente Chiave (lette a runtime, niente rebuild)
- `POSTGRES_URL_NON_POOLING` / `POSTGRES_PRISMA_URL`: connessione DB
- `BASE_URL`: URL pubblico (default `http://localhost:3000`)
- `DEFAULT_CURRENCY_CODE`: valuta predefinita nuovi gruppi (default `USD`)
- `ENABLE_EXPENSE_DOCUMENTS`: upload documenti (richiede S3)
- `ENABLE_RECEIPT_EXTRACT`: scansione ricevute (richiede OpenAI + documenti)
- `ENABLE_CATEGORY_EXTRACT`: deduzione categoria (richiede OpenAI)
- `S3_UPLOAD_*` (anche `S3_UPLOAD_ENDPOINT` per provider S3 alternativi)
- `OPENAI_API_KEY`, opzionali `OPENAI_BASE_URL`, `OPENAI_MODEL_RECEIPT_EXTRACT`, `OPENAI_MODEL_CATEGORY_EXTRACT`
- Le vecchie `NEXT_PUBLIC_*` (build-time) funzionano ancora, ma la variante runtime ha la precedenza

## Comandi Utili
- `npm run dev`: sviluppo locale
- `npm run build`: build produzione
- `npm run start`: avvio produzione
- `npm run prettier`: formattazione codice
- `npm run lint` (oxlint), `npm run check-types` (tsc), `npm test` (jest)
- `npm run e2e`: test Playwright contro l'app in Docker (`compose.e2e.yaml`)
- `npm run perf`: suite di performance (`perf/README.md`, `compose.perf.yaml`)
- `./scripts/start-local-db.sh`: avvia DB PostgreSQL locale
