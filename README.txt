If you want to run the code yourself, it is setup to do so with a ridiculously downscaled image, as controlled by the "num_pixels"
parameter in the pipeline, comparison_figure, and truth_rand_index scripts. 

The pipeline.m script generates images showing the results of self-tuning spectral clustering in all six conditions:
No coarsening, edge matching, and spectral graph coarsening, all +/- texture and intensity.

After running this and saving final_data, run the comparison_figure to see the results in each condition or the truth_rand_index to 
get the rand index score comparing the results to the truth mask images.


An explanation of each file:
1) add_texture: adds a texture layer to an image
2) comparison_figure: shows the results of the clustering done by the pipeline
3) edge_matching: runs the edge_matching algorithm to condense the graph
4) graph_coarsener: runs the spectral graph coarsening algorithm to condense a graph by a desired amount
5) im_to_graph: turns an image (or really any observations x features array) into a sparse graph with a given number of neighbours
6) pipeline: runs all the experimental conditions, gives the clustering results as a color coded image
7) rand_index: computes the rand index.
8) truth_rand_index: compares the clustering results to the truth masks of the hand segmented images.

And the folders
9) figures: these are the figures made by comparison_figure.m.
10) originals: the original images
11) toy_example: toy examples using the EM and GC algorithm on the examples from HW4
12) truth_masks: hand segmented images