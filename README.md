# Project Overview

CSCI 331 Databases & Data Modeling with Peter Heller
CUNY Queens College - Fall 2023

This project is the culmination of a semester-long collaborative effort. Our group was to transform a basic flat data file into a robust, 3rd Normal Form (3NF) compliant database. The dataset comprises detailed class information for the current semester, including sections, building locations, professor assignments, and departmental data. Our primary focus was to ensure data integrity, clarity, and efficiency throughout the database design process.

## Results

[Project3MainScript.sql](https://github.com/aleksgeorgi/Databases-FinalProject/blob/main/Project3MainScript.sql)

## Team Members:

- Aleksandra Georgievska (Team Lead)
- Nicholas Kong
- Aryeh Richman
- Edwin Wray
- Sigalita Yakubova
- Ahnaf Ahmed

## Key Features & Technical Highlights

- **Data Normalization:** We successfully converted a flat data file into a normalized database, adhering strictly to 3NF principles. This involved an intricate process of segregating data into logically structured tables to eliminate redundancy and dependencies.

- **Error Identification and Data Integrity:** Our team identified and rectified data anomalies. We implemented constraints within our Entity-Relationship Diagram (ERD) to enhance data integrity, ensuring accurate and consistent information across the database.

- **Schema Design:** We designed thoughtful schema names to segregate tables into distinct subsystems. This approach facilitated a more organized and intuitive database structure, aiding in easier data management and query optimization.

- **User-Defined Data Types (UDTs):** We created self-documenting UDTs, which enhanced the data quality and brought uniformity and clarity to our database design.

- **Self-Documenting Naming Conventions:** Our naming conventions were meticulously planned to be self-explanatory, making the database more intuitive for future users.

- **Key Relationships:** We established primary keys and foreign key relationships with a focus on referential integrity and efficient data retrieval.

- **Surrogate Keys Implementation:** All surrogate keys in our database employ identity properties, ensuring uniqueness and consistency in record identification.

- **Atomicity in Column Design:** We created atomic columns, ensuring each field captured the lowest level of user-relevant data for increased precision and normalization.

- **Stored Procedures:** A suite of stored procedures was developed for:

  - Loading the production model
  - Truncating tables
  - Adding/Dropping foreign keys
  - Individual table data loading

  These procedures optimized our database management processes, making them more efficient and less prone to error.

- **Workflow Management:** We developed a specialized stored procedure to monitor all workflow steps. This feature includes user authorization tracking, providing an audit trail and enhancing the security and reliability of our database operations.

## Summary

This project showcased our team's capability in database design, data integrity assurance, and efficient data management. We believe that the skills demonstrated here, including attention to detail, problem-solving, and technical proficiency in SQL and database administration, will be invaluable in professional data engineering roles.

## Project Presentation Video

[![ProjectPresentationVideo](https://i.imgur.com/wwqR3jG.png)](https://youtu.be/x727eloWgkE)

## Select Project Presentation Slides

![Imgur](https://i.imgur.com/fb6ORwt.png)

![Imgur](https://i.imgur.com/NF1WRdJ.png)

![Imgur](https://i.imgur.com/LSBMztq.png)

![Imgur](https://i.imgur.com/tHv8REX.png)

![Imgur](https://i.imgur.com/4170HNB.png)

![Imgur](https://i.imgur.com/YAYTxu1.png)

![Imgur](https://i.imgur.com/jaEaKT1.png)
