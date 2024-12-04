# Snowflake-Yeast-Simulation

This is part of a project for my research lab investigating snowflake yeast. Specifically, this project aims to procedurally generate a physical snowflake yeast cluster in Godot 3.5 to use in kinematic porosity simulations. 

![image](https://github.com/user-attachments/assets/0e6cd27d-aff5-4334-9af9-d8666f70b2d9)

In general, it works by taking a capsule-shaped "cell", generating candidates for subsequent "daughter" cells based on random points on a hemisphere, and then adds them to a list, from which they are randomly chosen and generated. Currently it has issues with overlapping itself and certain cells being generated at unrealistic angles.
