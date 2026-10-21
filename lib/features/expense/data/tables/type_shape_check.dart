// Shape of each transaction type (feature 002 research R3), shared by
// `transactions` and `recurring_rules` (feature 003 data-model.md §3.1).
// Indexes: expense 0, income 1, transfer 2. A transfer has a different
// destination account and no category; expense and income have a category
// and no destination account. One constant per table because the type
// column is named differently.

const String transactionsTypeShapeCheck =
    'CHECK ((type = 2 AND to_account_id IS NOT NULL AND category_id IS NULL '
    'AND to_account_id <> account_id) OR (type IN (0, 1) AND '
    'category_id IS NOT NULL AND to_account_id IS NULL))';

const String recurringRulesTypeShapeCheck =
    'CHECK ((template_type = 2 AND to_account_id IS NOT NULL AND '
    'category_id IS NULL AND to_account_id <> account_id) OR '
    '(template_type IN (0, 1) AND category_id IS NOT NULL AND '
    'to_account_id IS NULL))';
