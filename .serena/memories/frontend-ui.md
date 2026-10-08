# Spliit - Frontend e UI

## Struttura App Router (Next.js 16)
```
src/app/
├── groups/
│   ├── [groupId]/
│   │   ├── expenses/          # Lista e gestione spese
│   │   │   ├── create/        # Creazione spesa
│   │   │   ├── [expenseId]/edit/  # Modifica spesa
│   │   │   └── export/        # Export CSV/JSON
│   │   ├── balances/          # Bilanci e rimborsi
│   │   ├── activity/          # Log attività
│   │   ├── stats/             # Statistiche
│   │   ├── information/       # Info gruppo
│   │   └── edit/              # Modifica gruppo
│   ├── create/                # Creazione gruppo
│   └── page.tsx               # Lista gruppi recenti
├── api/
│   ├── trpc/[trpc]/          # Endpoint tRPC
│   ├── s3-upload/            # Upload S3
│   └── health/               # Health checks
└── layout.tsx                # Layout root con providers
```

## Componenti Principali

### Form Spese (`expense-form.tsx`)
- **Form library**: react-hook-form + zod validation
- **Features**:
  - Input importo con validazione pattern valuta
  - Selezione pagatore e beneficiari
  - 4 modalità split (EVENLY, BY_SHARES, BY_PERCENTAGE, BY_AMOUNT)
  - Conversione valuta automatica (con API tassi cambio)
  - Upload documenti (se abilitato)
  - Estrazione categoria da titolo (OpenAI, se abilitato)
  - Ricorrenza spese (DAILY, WEEKLY, MONTHLY)
  - Salvataggio preferenze split in localStorage

### UI Components (shadcn/UI)
- Basati su Radix UI primitives
- Styling con TailwindCSS + class-variance-authority
- Componenti custom: Money, CategorySelector, CurrencySelector, ExpenseDocumentsInput

## Internazionalizzazione
- **Library**: next-intl
- **Lingue supportate**: 38 (vedi `messages/`, traduzioni gestite su Weblate)
- **Pattern**: `useTranslations('namespace')` nei componenti

## State Management
- **Server state**: tRPC + TanStack Query
- **Client state**: React hooks + Context API
- **Persistenza locale**: localStorage per preferenze utente

## Feature Flags Runtime
`getRuntimeFeatureFlags()` in `src/lib/featureFlags.ts` (server action): legge `ENABLE_*` da `process.env` a runtime, con fallback alle `NEXT_PUBLIC_*` di build:
- `enableExpenseDocuments`
- `enableReceiptExtract`
- `enableCategoryExtract`

## Utility Functions (`src/lib/utils.ts`)
- `formatCurrency()`: formattazione importi
- `amountAsMinorUnits()` / `amountAsDecimal()`: conversione valuta
- `getCurrencyFromGroup()`: estrazione valuta da gruppo
- `cn()`: merge classi Tailwind
