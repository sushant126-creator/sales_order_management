# User Stories & Acceptance Criteria
### Project: Sales Order Management & Customer Analytics System

| | |
|---|---|
| **Document Version** | 1.0 |
| **Author** | Business Analyst |
| **Traces To** | BRD v1.0, FSD v1.0 |
| **Last Updated** | 2026-08-26 |

---

## US-01: Daily Sales & Pending Orders Dashboard

**As a** Sales Operations Manager
**I want** to see daily total sales and pending orders
**So that** I can allocate warehouse staff efficiently

### Acceptance Criteria

| # | Criteria (Given / When / Then) |
|---|---|
| AC-1 | **Given** orders exist in the system, **when** the dashboard loads for the current day, **then** it displays the sum of `TotalAmount` for all orders placed that day (Daily Revenue). |
| AC-2 | **Given** orders exist with `Status = 'Pending'`, **when** the dashboard loads, **then** it displays a count of all orders currently in `Pending` status, regardless of order date. |
| AC-3 | **Given** the dashboard has already loaded, **when** a new day begins, **then** the Daily Revenue figure resets and recalculates for the new day automatically (daily refresh, not real-time). |
| AC-4 | **Given** no orders exist for the current day, **when** the dashboard loads, **then** Daily Revenue displays as 0, not blank or an error. |

### Supporting Query Logic
```sql
-- Daily Revenue
SELECT SUM(TotalAmount) AS DailyRevenue
FROM Orders
WHERE DATE(OrderDate) = CURDATE();

-- Pending Order Count
SELECT COUNT(*) AS PendingOrders
FROM Orders
WHERE Status = 'Pending';
```

---

## US-02: Order Status Visibility

**As an** Operations Manager
**I want** to see the current status of every order
**So that** I can identify delays in the order lifecycle

### Acceptance Criteria

| # | Criteria |
|---|---|
| AC-1 | **Given** an order exists, **when** I view the order list, **then** its `OrderStatus` and `OrderDate` are displayed. |
| AC-2 | **Given** an order has been in `Processing` for longer than 2 days, **when** I view the order list, **then** it is visually flagged as delayed. |

---

## US-03: Automatic VIP Order Flagging

**As a** Sales Lead
**I want** orders over $1,000 automatically flagged as VIP
**So that** they get prioritized for processing

### Acceptance Criteria

| # | Criteria |
|---|---|
| AC-1 | **Given** an order with `TotalAmount` > 1000, **when** the order is saved, **then** `OrderPriority` is automatically set to `'VIP'`. |
| AC-2 | **Given** an order with `TotalAmount` \u2264 1000, **when** the order is saved, **then** `OrderPriority` is set to `'Standard'`. |

*(Implemented in the schema as a generated column — see `sales_order_management_schema.sql`.)*

---

## US-04: Mandatory Cancellation Reason

**As a** Customer Support Lead
**I want** a mandatory cancellation reason on every cancelled order
**So that** churn causes can be analyzed

### Acceptance Criteria

| # | Criteria |
|---|---|
| AC-1 | **Given** a user sets `OrderStatus` to `'Cancelled'`, **when** they attempt to save without a `CancellationReason`, **then** the system blocks the save and returns an error. |
| AC-2 | **Given** a cancelled order has a `CancellationReason`, **when** a churn report is generated, **then** that reason is included in the report grouping. |

*(Implemented as `BEFORE INSERT` / `BEFORE UPDATE` triggers — see `sales_order_management_schema.sql`.)*

---

## US-05: Customer Purchase Behavior Reporting

**As a** Sales Lead
**I want** a report of orders grouped by customer and status
**So that** I can review purchasing patterns and identify at-risk customers

### Acceptance Criteria

| # | Criteria |
|---|---|
| AC-1 | **Given** order and customer data exist, **when** the report is run, **then** results are grouped by `CustomerID` and `OrderStatus`. |
| AC-2 | **Given** a customer has multiple cancelled orders, **when** the report is run, **then** that customer is highlighted as a churn risk. |

---

## Traceability Summary

| User Story | Traces to BRD Need | Traces to FSD Rule/Field |
|---|---|---|
| US-01 | BN-05 (reduce processing delay) | OrderDate, Status |
| US-02 | BN-01 (order lifecycle tracking) | OrderStatus, OrderDate |
| US-03 | BN-02 (VIP orders) | BR-01, OrderPriority |
| US-04 | BN-03 (cancellation reasons) | BR-02, CancellationReason |
| US-05 | BN-04 (purchasing behavior) | CustomerID, OrderStatus |
