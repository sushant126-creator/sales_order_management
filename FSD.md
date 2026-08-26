# Functional Specification Document (FSD)
### Project: Sales Order Management & Customer Analytics System

| | |
|---|---|
| **Document Version** | 1.0 |
| **Author** | Business Analyst |
| **Status** | Draft |
| **Traces To** | BRD v1.0 |
| **Last Updated** | 2026-08-26 |

---

## 1. Purpose

This document translates the business objectives defined in the BRD into functional requirements —
specific fields, data rules, and system behavior — that developers and QA can build and test against.

## 2. Required Fields

| Field | Description | Data Type | Traces to BRD |
|---|---|---|---|
| `CustomerID` | Unique identifier for a customer | INT (PK) | BN-04 |
| `OrderID` | Unique identifier for a sales order | INT (PK) | BN-01 |
| `ProductID` | Unique identifier for a product in an order | INT (FK) | BN-04 |
| `OrderStatus` | Current stage in the order lifecycle | ENUM('Order','Processing','Shipped','Delivered','Cancelled') | BN-01 |
| `OrderDate` | Date/time the order was placed | DATETIME | BN-01, BN-05 |
| `PaymentAmount` | Total monetary value of the order | DECIMAL(12,2) | BN-02 |
| `CancellationReason` | Reason logged when an order is cancelled | VARCHAR(255), nullable | BN-03 |
| `OrderPriority` | Priority flag derived from order value | ENUM('Standard','VIP') | BN-02 |

## 3. Business Rules

| Rule ID | Rule | Trigger | Traces to BRD |
|---|---|---|---|
| BR-01 | Orders with `PaymentAmount` > 1000 qualify for VIP processing (`OrderPriority = 'VIP'`) | On order creation / update | BN-02 |
| BR-02 | If `OrderStatus = 'Cancelled'`, `CancellationReason` must not be null or blank | On status change to Cancelled | BN-03 |
| BR-03 | `OrderStatus` must follow the sequence Order → Processing → Shipped → Delivered, or move to Cancelled from any non-Delivered state | On status update | BN-01 |
| BR-04 | `OrderDate` cannot be a future date | On order creation | BN-01 |
| BR-05 | A VIP order (`OrderPriority = 'VIP'`) should be flagged for priority processing to the Operations queue | On order creation | BN-05 |

## 4. Functional Requirements (User-Story Style)

| ID | User Story | Acceptance Criteria |
|---|---|---|
| FR-01 | As an Operations Manager, I want to see the current status of every order, so that I can identify delays. | Given an order exists, when I view the order list, then its `OrderStatus` and `OrderDate` are displayed. |
| FR-02 | As a Sales Lead, I want orders over $1,000 automatically flagged as VIP, so that they get prioritized. | Given an order with `PaymentAmount` > 1000, when the order is saved, then `OrderPriority` is set to 'VIP'. |
| FR-03 | As a Customer Support Lead, I want a mandatory cancellation reason, so that churn causes can be analyzed. | Given a user sets `OrderStatus` to 'Cancelled', when they attempt to save without a `CancellationReason`, then the system blocks the save and prompts for a reason. |
| FR-04 | As a Sales Lead, I want a report of orders by customer and status, so that I can review purchasing behavior. | Given order and customer data exist, when the report is run, then results are grouped by `CustomerID` and `OrderStatus`. |

## 5. Non-Functional Considerations

- Reports should load within acceptable time for daily business use (dashboard refresh, not real-time).
- Data validation rules (BR-01 to BR-04) should be enforced at the database or application layer, whichever is implemented, to prevent invalid data from entering reporting.

## 6. Out of Scope (Restated from BRD)

- Payment processing/gateway logic
- Inventory management
- Marketing/campaign features

## 7. Traceability Summary

| BRD Business Need | FSD Field(s) | FSD Rule(s) |
|---|---|---|
| BN-01 | OrderID, OrderStatus, OrderDate | BR-03, BR-04 |
| BN-02 | PaymentAmount, OrderPriority | BR-01, BR-05 |
| BN-03 | CancellationReason | BR-02 |
| BN-04 | CustomerID, ProductID | — |
| BN-05 | OrderDate, OrderPriority | BR-05 |
