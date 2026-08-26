
# Sales Order Management & Customer Analytics System

A portfolio project that walks through a sales order system the way a business analyst would
build it: start with requirements, design the database, write the SQL to validate and analyze the
data, then turn it into reporting dashboards.

## Objective

Track orders through their lifecycle (Order, Processing, Shipped, Delivered) and look at customer
purchasing patterns to help reduce processing delays and churn.

## Tools

MySQL, SQL (SELECT, JOIN, GROUP BY, subqueries), MS Excel (pivot tables, VLOOKUP, charts),
Power BI (DAX, data modeling), Jira, Agile.

## Folder Structure

```
sales-order-management-analytics/
│
├── docs/
│   ├── BRD.md
│   ├── FSD.md
│   └── USER_STORIES.md
│
├── sql/
│   ├── sales_order_management_schema.sql
│   ├── sales_order_management_sample_data.sql
│   └── sales_order_management_analysis_queries.sql
│
├── excel/
│   └── sales_order_management_dashboard.xlsx
│
├── powerbi/
│   └── (report file / screenshots)
│
└── README.md
```

## What's in each part

**docs/** has the BRD (objective, stakeholders, scope), the FSD (fields and business rules like
the VIP order threshold and the required cancellation reason), and a user stories doc with
acceptance criteria for each rule.

**sql/** has the schema (7 tables — Customers, Categories, Products, Employees, Orders,
OrderDetails, Transactions), the sample data, and a set of queries split into four groups:
data validation (duplicate emails, orphan orders, reconciliation), customer analysis (revenue per
customer, churn risk, above-average spenders), product/order analysis (best sellers, VIP vs
Standard split), and transaction analysis (revenue by payment method, failed/pending payments).

Two business rules are enforced directly in the database instead of just being documented:
- Orders over $1,000 get flagged VIP automatically (a generated column based on order total)
- A cancelled order can't be saved without a cancellation reason (enforced with triggers)

**excel/** has a dashboard built from the sample data — KPI cards for revenue, orders, customers,
and average order value, plus charts for category sales, monthly revenue, and order status. The
category/customer/region fields are pulled in with VLOOKUP rather than typed in by hand, and the
data is set up as a table so it's ready to turn into real PivotTables with slicers.

**powerbi/** — data model with Customers to Orders as a 1-to-many relationship, DAX measures for
total revenue and customer count, and cards/charts for the same three views as the Excel version.

## Running it

1. Run `sales_order_management_schema.sql` in MySQL
2. Run `sales_order_management_sample_data.sql` to load sample data
3. Run the queries in `sales_order_management_analysis_queries.sql` to check and analyze the data
4. Open the Excel file for the pivot-style dashboard
5. Open the Power BI report for the interactive version

## Screenshots

*(add dashboard screenshots<img <img width="1012" height="617" alt="image" src="https://github.com/user-attachments/assets/1db95157-e8a4-4a19-8ece-48ce3f02ddac" />
 />
 here)*

\
```
