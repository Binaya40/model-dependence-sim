# Understanding Model Dependence in Policy Evaluation: A Simulated Vocational Training Example

This repository contains a simulated dataset and R code used to demonstrate how different model specifications influence causal conclusions in policy evaluation. The example focuses on a hypothetical vocational training program and provides a simple, reproducible illustration of **model dependence**.

---

## Purpose of the Repository
This repository demonstrates how causal conclusions—such as program impact estimates—can vary significantly based on the chosen model. The goal is to help learners, students, and practitioners appreciate:

- The sensitivity of policy impact to modeling choices  
- Why model dependence matters in policy evaluation  

This resource is designed for:
- Teaching and classroom demos  
- Illustrations for blog posts or academic talks  

---

## Repository Contents

### **1. [`training_data.csv`](training_data.csv)**
A fully simulated dataset representing a hypothetical vocational training intervention. The dataset contains following variables:
- **Outcome (y):** Monthly earnings (log-normal).  
- **Treatment (T):** Participation in a training program (non-random; depends on covariates).  
- **Covariates:**
  - Baseline earnings (x1, log-normal)
  - Years of schooling (x2, true value)
  - Female (x3)
  - Married (x4)
  - Self-reported schooling (x5, mismeasured proxy for x2)
  - Urban (x6) 

**NOTE:** This dataset is not real and should not be used for research.  
See `DATA_LICENSE.txt` for license and disclaimer.

### **2. [`code/simulation.R`](code/simulation.R)**
Code to generate the simulated dataset. The simulation encodes:
- *True treatment effect that differs for married vs. unmarried groups*  
- *Strong selection into treatment based on covariates*
- *Measurement error in schooling*
- *Selection into the observed sample (S=1)*

### **3. [`code/analysis.R`](code/analysis.R)**
R script demonstrating:
- Construction of multiple model specifications  
- Comparison of estimated program effects under different models  
- Visualization of how causal conclusions change depending on modeling choices  

### **4. [`DATA_LICENSE.txt`](DATA_LICENSE.txt)**
The dataset is released under **CC BY-NC 4.0** and includes a full disclaimer stating that the data is simulated and unsuitable for empirical research.

### **5. [`LICENSE`](LICENSE)**
MIT License for code. You may reuse or modify the **code** for any purpose.

---

## Getting Started

### **Requirements**
- R (version 4.0 or later)
- The following R packages:  
  `tidyverse`, `ggplot2`, `broom`, `sandwich` 

### **Running the Analysis**
1. Clone this repository  
2. Open the R script: `code/analysis.R`  
3. Run the script to reproduce the figures and output

---

## Important Disclaimer

The dataset in this repository is **fictional** and generated solely for demonstration.  
It must **not** be used for research, publication, evaluation, or policy analysis.

---

## Learn More
"The Program Worked. Or Did It"? How Model Dependence Shapes Policy Evidence
https://binayachalise.com.np/2025/12/05/251206/

---

## Citation

If you use or reference this repository in teaching materials or presentations:

Binaya Chalise (2025). *Understanding Model Dependence in Policy Evaluation: A Simulated Vocational Training Example*. GitHub Repository.

---

## Contact

If you have questions, feel free to open an issue or contact the author.

