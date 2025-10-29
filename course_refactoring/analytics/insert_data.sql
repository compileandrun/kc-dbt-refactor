INSERT INTO manifest-surfer-352407.refactoring_raw.orders
(id, user_id, order_date, status)
VALUES
(100, 100, '2025-02-15', 'shipped'),
(101, 84, '2025-02-15', 'shipped'),
(102, 42, '2025-02-15', 'shipped'),
(103, 101, '2025-02-15', 'shipped'),
(104, 66, '2025-02-15', 'shipped');

INSERT INTO manifest-surfer-352407.refactoring_raw.customers
(id, first_name, last_name)
VALUES
(101, 'Michelle', 'B.'),
(102, 'Faith', 'L.');

INSERT INTO manifest-surfer-352407.refactoring_raw.payments
(id, orderid, paymentmethod, status, amount, created)
VALUES
(121, 100, 'bank_transfer', 'success', 1000, '2025-02-14' ),
(122, 101, 'credit_card', 'fail', 400, '2025-02-14' ),
(123, 102, 'credit_card', 'success', 1900, '2025-02-14' ),
(124, 103, 'credit_card', 'success', 1000,  '2025-02-15' ),
(125, 104, 'coupon', 'success', 100, '2025-02-15' );