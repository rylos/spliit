# Spliit - Architettura e Logica Business

## Architettura tRPC
- **Router principale**: `src/trpc/routers/_app.ts`
- **Procedure**: organizzate per dominio (groups, expenses, categories, activities, balances, stats)
- **Pattern**: ogni feature ha un router con procedure separate per operazioni CRUD

## Logica Calcolo Bilanci (`src/lib/balances.ts`)

### Tipi
```typescript
type Balances = Record<ParticipantId, { paid: number; paidFor: number; total: number }>
type Reimbursement = { from: ParticipantId; to: ParticipantId; amount: number }
```

### Funzioni Chiave

#### `getBalances(expenses)`
Calcola i bilanci per ogni partecipante:
1. Itera su tutte le spese
2. Aggiunge l'importo pagato al `paid` del pagatore
3. Distribuisce l'importo tra i beneficiari secondo lo `splitMode`:
   - `EVENLY`: divide equamente
   - `BY_SHARES`: divide per quote
   - `BY_PERCENTAGE`: divide per percentuale
   - `BY_AMOUNT`: divide per importo specifico
4. Arrotonda i valori e calcola `total = paid - paidFor`

**Nota importante**: l'ultimo beneficiario riceve il `remaining` per evitare errori di arrotondamento.

#### `getSuggestedReimbursements(balances)`
Algoritmo greedy per minimizzare i rimborsi:
1. Ordina i bilanci (positivi prima, poi per ID partecipante)
2. Accoppia il maggior creditore con il maggior debitore
3. Crea rimborso per l'importo minore tra i due
4. Aggiorna i bilanci e ripete fino a saldare tutti

#### `getPublicBalances(reimbursements)`
Calcola bilanci da una lista di rimborsi (usato per visualizzazione pubblica).

## Schema Spese (`expenseFormSchema`)
Definito in `src/lib/schemas.ts`, valida:
- Titolo, importo, data
- Pagatore e beneficiari
- Modalità split e relative quote/percentuali/importi
- Categoria, note, documenti
- Conversione valuta (opzionale)
- Ricorrenza (opzionale)

## Creazione Spese
- **Procedure**: `createGroupExpenseProcedure` in `src/trpc/routers/groups/expenses/create.procedure.ts`
- **API**: `createExpense()` in `src/lib/api.ts`
- Supporta spese ricorrenti tramite `RecurringExpenseLink`
