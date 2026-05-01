# 🌬️ Wind Energy Modeling using Weibull Distribution & Monte Carlo Simulation

## 📌 Overview
This project presents a probabilistic framework for analyzing wind energy generation under uncertain wind conditions.

Wind speed is modeled using the Weibull distribution, and the turbine behavior is represented using a power curve. The model combines statistical analysis with numerical computation to estimate wind turbine performance.

## ⚙️ Key Features
- Weibull distribution modeling of wind speed
- Wind turbine power curve implementation
- Expected power output calculation
- Variance and uncertainty analysis
- Capacity factor estimation
- Monte Carlo simulation

## 🧠 Methodology

### 1. Wind Speed Modeling
Wind speed is treated as a random variable and modeled using the Weibull distribution with:
- Shape parameter (k)
- Scale parameter (c)

### 2. Power Curve Modeling
The turbine operates in three regions:
- Cut-in region (no power)
- Increasing power region
- Rated power region

### 3. Probabilistic Power Estimation
Expected power is calculated using numerical integration:

E[P] = ∫ P(v) f(v) dv

### 4. Monte Carlo Simulation
Random wind samples are generated based on the Weibull distribution to simulate real-world variability and estimate system performance.

## 📈 Key Equation
Wind power is proportional to the cube of wind speed:

P = 0.5 × ρ × A × V³

## 📊 Results
The model computes:
- Expected Power Output
- Power Variance
- Capacity Factor
- Performance under uncertainty

## 🖥️ Sample Output (Add your results here)
- Expected Power = XXX W
- Capacity Factor = XX%
- Graphs: Power vs Wind Speed

## 🛠️ Tools & Technologies
- MATLAB
- Numerical Methods
- Probability & Statistics

## ▶️ How to Run
1. Open MATLAB
2. Run the main script
3. View results and generated outputs

## 🚀 Applications
- Wind farm planning
- Renewable energy integration
- Power system reliability studies

## 🔮 Future Improvements
- Real wind data integration
- Optimization of turbine parameters
- GUI for visualization

## 👨‍💻FIVE NINESS 
Faculty of Engineering - Electrical Power Department
