# Business Requirement Document (BRD)
### Project: Sales Order Management & Customer Analytics System

| | |
|---|---|
| **Document Version** | 1.0 |
| **Author** | Business Analyst |
| **Status** | Draft for Stakeholder Review |
| **Last Updated** | 2026-08-26 |

---

## 1. Business Objective

Track the complete sales order lifecycle **(Order → Processing → Shipped → Delivered)** and analyze
customer purchasing behavior in order to:

- Reduce order processing delays
- Improve visibility into order status across teams
- Identify patterns that contribute to customer churn
- Enable data-driven decisions through customer and sales analytics

## 2. Background / Problem Statement

Orders currently move through multiple stages without a single, reliable source of truth for status,
payment, and cancellation data. This makes it difficult to identify where delays occur, which
customers are at risk of churning, and which orders require priority handling.

## 3. Stakeholders

| Stakeholder | Role / Interest |
|---|---|
| **Operations Manager** | Needs visibility into order status and processing bottlenecks to reduce delays |
| **Sales Lead** | Needs insight into high-value (VIP) orders and customer purchasing trends |
| **Customer Support Lead** | Needs cancellation reasons logged to identify and address churn drivers |

## 4. Scope

### In Scope
- Order lifecycle tracking (creation through delivery)
- Customer purchase history and segmentation
- VIP order identification based on order value
- Cancellation reason capture and reporting
- Sales and customer analytics/dashboards

### Out of Scope
- Payment gateway integration (transactions are recorded, not processed, in this system)
- Inventory/warehouse management
- Marketing campaign management

## 5. Business Needs

| ID | Business Need | Raised By |
|---|---|---|
| BN-01 | Track order status at every lifecycle stage | Operations Manager |
| BN-02 | Flag and prioritize high-value orders (VIP) | Sales Lead |
| BN-03 | Capture a reason whenever an order is cancelled | Customer Support Lead |
| BN-04 | Provide reporting on customer purchase patterns and churn indicators | Sales Lead / Support Lead |
| BN-05 | Reduce average order processing time | Operations Manager |

## 6. Assumptions

- Order and customer data will be maintained in a relational database (MySQL).
- Business users will access insights via dashboards (Power BI / Excel), not directly querying the database.
- Currency for all monetary values is INR unless stated otherwise.

## 7. Constraints

- Solution must work with existing order and payment data formats.
- Reporting must be refreshable on at least a daily basis.

## 8. Success Metrics / KPIs

| KPI | Target |
|---|---|
| Average order processing time | Reduced by 20% |
| % of cancelled orders with a logged reason | 100% |
| Customer churn rate | Measurable and trending downward quarter over quarter |
| VIP orders correctly flagged | 100% accuracy against the $1,000 threshold |

## 9. Approval

| Name | Role | Signature | Date |
|---|---|---|---|
| | Operations Manager | | |
| | Sales Lead | | |
| | Customer Support Lead | | |
