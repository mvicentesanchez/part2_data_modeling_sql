# Part 2: Data Modeling with SQL

## Scenario: 
As part of a data warehousing initiative, you are required to design a data mart for analyzing sales data. The data mart should be designed using the Data Vault modeling approach. You need to create SQL scripts to define the structure of the data mart.

## Task: 
Design the SQL scripts to create the necessary tables for the data mart using the Data Vault modeling approach. Assume the data mart will store information about sales transactions, customers, and products.
Include the following tables:
•	Hub tables for customers and products.
•	Satellite tables for tracking historical changes to customer and product attributes.
•	Link table to associate sales transactions with customers and products.
•	Include primary and foreign key constraints where necessary.

## Additional Challenges:

1.	Data Mart Population: Populate the data mart with sample data to test the effectiveness of the created SQL scripts.
2.	Incremental Loading: Modify the scripts to support incremental loading, ensuring that only new records are added to the data mart during each update.
3.	Surrogate Keys: Implement surrogate keys for hub tables to uniquely identify each record and simplify data integration.
4.	Slowly Changing Dimensions (SCDs): Extend the satellite tables to support various types of slowly changing dimensions (e.g., Type 1, Type 2), enabling tracking of historical changes to customer and product attributes.
5.	Partitioning and Compression: Optimize table storage by incorporating partitioning and compression techniques, improving query performance and reducing storage requirements.
6.	Error Handling and Logging: Implement error handling mechanisms in the SQL scripts to handle data validation errors and ensure comprehensive logging of data loading activities.
7.	GitHub Integration: Utilize GitHub for version control, creating a repository to manage the development of the SQL scripts, including branches for feature development, issue tracking, and collaborative code review.
   
## Requirements:
•	Utilize SQL to create the tables according to the Data Vault modeling approach.
•	Ensure proper indexing for performance optimization.
•	Incorporate mechanisms for tracking historical changes to customer and product attributes.
•	Define primary and foreign key constraints to maintain data integrity.

## Additional Evaluation Criteria:

•	Appropriateness and completeness of the Data Vault modeling approach.
•	Correctness and efficiency of the SQL scripts, including scalability considerations.
•	Handling of historical changes, data integrity constraints, error handling mechanisms, and GitHub integration.
•	Clarity and readability of the SQL code and accompanying documentation.
