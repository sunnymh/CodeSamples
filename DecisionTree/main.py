from __future__ import division
import scipy.io
import math
import operator
import numpy as np
import pickle

class Node:

	def is_leaf(self):
		raise NotImplementedError()


class LeafNode(Node):
	"""
	A LeafNode is used to store the label.
	"""

	def __init__(self, label, level):
		self.label = label
		self.level = level

	def is_leaf(self):
		return True

	def print_tree(self):
		print("\t" * self.level  + "( " + str(self.label) + " )" )

	def classify(self, x):
		return self.label


class TreeNode(Node):
    """
    A TreeNode is used to store threshold and feature_index for non-leaf nodes.
    """  
    def __init__(self, threshold, feature_index, left, right, level):
    	self.threshold = threshold
    	self.feature_index = feature_index
    	self.left = left
    	self.right = right
    	self.level = level

    def print_tree(self):
    	self.right.print_tree()
    	print("\t" * self.level + "F" + str(self.feature_index) + " <= " + str(self.threshold))
    	self.left.print_tree()
    	
    def is_leaf(self):
    	return False

    def classify(self, x):
    	if (x[self.feature_index]) <= self.threshold:
    		label = self.left.classify(x)
    	else:
    		label = self.right.classify(x)
    	return label 


def grow_booster(xy, num_iter = 50):
	"""
	Returns a non-numpy list of trees and a list of alphas.
	"""
	tree_list = []
	alpha_list = []
	d = np.array([1/len(xy)]*len(xy))
	alpha = 0
	stop_at_size = len(xy) * 0.4
	for t in range(0, num_iter):
		print("-------------------------")
		print("Starting iteration " + str(t))
		tree = grow_tree(xy, 0, True, stop_at_size, d, 1)
		# classification is True if classified wrong and False if right
		classification = (tree_classify(xy, tree) != xy[:,-1])
		error = sum(d[classification])
		if error > 0.5:
			break
		alpha = 0.5 * math.log(float((1-error))/error)
		tree_list.append(tree)
		alpha_list.append(alpha)
		save_obj(tree_list,'tree_list')
		save_obj(alpha_list,'alpha_list')
		# wrong ones:
		d[classification] = d[classification] * math.exp(alpha)
		# right ones:
		d[~classification] = d[~classification] * math.exp(-alpha)
		# normalize
		d[classification] = d[classification]/sum(d)
	return (tree_list, alpha_list)


def grow_forest(xy, num_trees = 11):
	""" 
	Returns an non-numpy array of trees. Default for # of trees is 11.
	"""
	forest = [None] * num_trees
	for i in range(0, num_trees):
		print ""
		print "Start growing tree " + str(i) + "........................"
		indices = np.random.randint(len(xy),size=len(xy))
		#print indices
		bootstraped_xy = xy[indices,:]
		#print bootstraped_xy
		forest[i] = grow_tree(bootstraped_xy, 0, True, 1, np.array([1]*len(xy)), -1)
	return forest


def grow_tree(xy, level, is_forest, stop_on_size, weights, count_level):
	"""
	Taking data and build a decision tree using entropy as cost.
	"""
	if stop_on_size < 1:
		raise Exception("stop_on_size should be >= 1.")
	print("Starting growing tree at level " + str(level) + "..........")
	#print xy
	# Case all labels are the same
	if calc_e(xy[:,-1], weights) == 0:
		return LeafNode(xy[0,-1], level)

	# Try to split it otherwise
	else:
		question = choose_question(xy, is_forest, weights)
		#print "optimal question" + str(question)
		infor_gain = question[2]

		# Case no information gain by splitting, create a LeafNode of 0 or 1
		if infor_gain == 0 or (len(xy) <= stop_on_size) or (level == count_level):
			prob0 = (sum(xy[:,-1]==0)/len(xy))
			if prob0 >= 0.5:
				return LeafNode(0, level)
			else:
				return LeafNode(1, level)

		# Create a TreeNode given the feature_index and threshold
		else:
			feature_index = question[0]
			threshold = question[1]
			left_indices = (xy[:, feature_index] <=threshold)
			xy_left = xy[left_indices]
			w_left = weights[left_indices]
			xy_right = xy[~left_indices]
			w_right = weights[~left_indices]
			return TreeNode(threshold, feature_index, 
				grow_tree(xy_left, level+1, is_forest, stop_on_size, w_left, count_level), 
				grow_tree(xy_right, level+1, is_forest, stop_on_size, w_right, count_level), 
				level)


def choose_question(xy, is_forest, weights):
	"""
	for each feature:
		find the best split
	return the feature_index, threshold, and information gain that optimizes the entropy gain.
	for forest, the features are sampled with replacement of size len(feature) ^ 0.5
	"""
	num_feature = xy.shape[1] - 1

	# Initialize
	feature_index = None 
	threshold_optimal = None
	weighted_e_optimal = float("Inf")

	# Get the set of feature indices to choose from with replacement.
	if is_forest:
		feature_index_set = np.random.permutation(num_feature)[:math.ceil(num_feature**0.5)]
	else:
		feature_index_set = range(0, num_feature)

	# Find the feature_index for which we have the minimum weighted_e, and get the corresponding threshold
	for i in feature_index_set:
		print("testing feature " + str(i))
		(threshold, weighted_e) = find_threshold(xy, i, weights)
		if (weighted_e < weighted_e_optimal):
			feature_index = i
			weighted_e_optimal = weighted_e
			threshold_optimal = threshold

	infor_gain = calc_e(xy[:,-1], weights) - weighted_e_optimal
	if math.fabs(infor_gain) <= 1e-10:
		infor_gain = 0
	
	return (feature_index, threshold_optimal, infor_gain)


def find_threshold(xy, feature_index, weights):
	"""
	Sort the data and iterate through all groups, aiming for the best split,
	returns a tuple of (threshold_value, weighted_entropy)
	"""
	xyw = np.column_stack((xy,weights))
	sorted_xyw = np.array(sorted(xyw, key=operator.itemgetter(feature_index)))
	sorted_xy = sorted_xyw[:,:(sorted_xyw.shape[1] -1)]
	sorted_w = sorted_xyw[:,-1]
	diff = np.ediff1d(sorted_xy[:,-1])
	indices = np.where(diff != 0)[0]
	if (indices == None or len(indices) == 0):
		raise Exception("The data is pure where it shouldn't.")
	min_so_far = float("inf")
	threshold_value = None
	current_threshold_value = None
	for i in indices:
		current_threshold_value = float((sorted_xy[i][feature_index] + sorted_xy[i+1][feature_index]))/2
		left_indices = sorted_xy[:,feature_index] <= current_threshold_value
		left = sorted_xy[left_indices]
		w_left = sorted_w[left_indices]
		right = sorted_xy[~left_indices]
		w_right = sorted_w[~left_indices]
		weighted_entropy = (calc_e(left[:,-1], w_left)*(len(left)) + calc_e(right[:,-1], w_right)*(len(right)))/len(xy)
		if weighted_entropy < min_so_far:
			min_so_far = weighted_entropy
			threshold_value = current_threshold_value
	return (threshold_value, min_so_far)


def calc_e(y, weights):
	"""
	Given a bunch of 0 and 1's, calculate its entropy.
	"""
	if len(y) == 0:
		return 0
	prob = sum(weights[y==0])/sum(weights)
	if prob==0 or prob==1:
		return 0
	return (- prob * math.log(prob, 2) - (1 - prob) * math.log(1 - prob, 2))


def booster_classify(x, tree_list, alpha_list):
	if len(tree_list) != len(alpha_list):
		raise Exception("tree_list and alpha_list have unequal length.")
	total = np.array([0] * len(x))
	for i in range(0, len(tree_list)):
		result = tree_classify(x,tree_list[i])
		result[result==0] = -1
		total = total + result * alpha_list[i]
	total[total<=0] = 0
	total[total>0] = 1
	return total


def forest_classify(x, forest):
	"""
	Predict the class of observations given the forest, voting by majority rule.
	"""
	result = np.zeros(shape=(len(forest), len(x)))
	for i in range(0, len(forest)):
		result[i,:] = tree_classify(x, forest[i])
	return vote(result)

def vote(decisions):
	"""
	Given a 2d array of votes, return an array of final decisions by majority rule.
	"""
	result = np.zeros(len(decisions[0]))
	for i in range(0, len(result)):
		data = decisions[:,i]
		result[i] = 1 if float(sum(data)/len(data))>=0.5 else 0
	return result


def tree_classify(x, tree):
	"""
	Predict the class of observations given the tree, x should be a 2d ndarray
	"""
	result = np.zeros(len(x))
	for i in range(0, len(x)):
		result[i] = tree.classify(x[i])
	return result


def forest_cv(xy_train_list, xy_test_list):
	""" 
	k-fold cross-validation for forest
	"""
	error_rates = np.zeros(len(xy_train_list))
	for i in range(0, len(xy_train_list)):
		xy_train = xy_train_list[i]
		xy_test = xy_test_list[i]
		forest = grow_forest(xy_train)
		result = forest_classify(xy_test, forest)
		error_rates[i] = float(sum(result != xy_test[:,-1])) / len(result)
	return np.mean(error_rates)


def tree_cv(xy_train_list, xy_test_list):
	""" 
	k-fold cross-validation for tree
	"""
	error_rates = np.zeros(len(xy_train_list))
	for i in range(0, len(xy_train_list)):
		xy_train = xy_train_list[i]
		xy_test = xy_test_list[i]
		tree = grow_tree(xy_train, 0, False, 1, np.array([1]*len(xy_train)), -1)
		result = tree_classify(xy_test, tree)
		error_rates[i] = float(sum(result != xy_test[:,-1])) / len(result)
	return np.mean(error_rates)


def split_data(xy, k=10):
	"""
	Returns a non-numpy list of length k, each contains a slice of xy.
	"""
	xy_train_list = [None] * k
	xy_test_list = [None] * k
	num_points = len(xy)
	by = num_points / k
	low_bounds = np.arange(0, num_points, by)[:k]
	high_bounds = np.append(low_bounds[1:k], num_points)
	xy_new = np.copy(xy) 
	np.random.shuffle(xy_new)
	for i in range(0, k):
		xy_train = np.vstack((xy_new[:low_bounds[i]], xy_new[high_bounds[i]:]))
		xy_test = xy_new[low_bounds[i] : high_bounds[i]]
		xy_train_list[i] = xy_train
		xy_test_list[i] = xy_test
	return (xy_train_list, xy_test_list)

def write_to_csv(numpy_array, name_of_file):
	seq = np.array(range(1,len(numpy_array)+1))	
	stuff = np.array([seq, numpy_array])
	stuff = np.swapaxes(stuff,0,1)
	format = "%d"
	with open(str(name_of_file)+".csv",'wb') as f:
		f.write('Id,Category\n')
		np.savetxt(f, stuff, fmt = format, delimiter = ",")

def read_csv(name_of_file):
	return np.genfromtxt(str(name_of_file)+'.csv', delimiter = ",")[1:,1]

def save_obj(obj, name_of_file):
	with open(str(name_of_file) + '.pkl','wb') as output:
		pickle.dump(obj, output, pickle.HIGHEST_PROTOCOL)	

def load_obj(name_of_file):
	with open(str(name_of_file)+ '.pkl','rb') as input:
		obj = pickle.load(input)
	return obj


BUILD_MODELS = False

if (BUILD_MODELS):
	# Processing data
	spam = scipy.io.loadmat('spam.mat')
	y_train = spam['ytrain']
	y_train = y_train[:,0]
	x_train = spam['Xtrain']
	xy_train = np.column_stack((x_train,y_train))
	x_test = spam['Xtest']
	
	np.random.seed(seed=10)

	# get split data for cv
	(xy_train_10folds, xy_test_10folds) = split_data(xy_train)

	# error rate of decision tree
	error_rate = tree_cv(xy_train_10folds, xy_test_10folds)
	# 0.081449275362318843

	# get decision tree full model
	dTree = grow_tree(xy_train, 0, False, 1,np.array([1]*len(xy_train)), -1)
	save_obj(dTree, "decision_tree")
	result_dTree = tree_classify(x_test, dTree)
	write_to_csv("result_dTree")

	# cross validation on forest
	error_rate = forest_cv(xy_train_10folds, xy_test_10folds) 
	#0.049565217391304338

	# get random forest full model
	rForest = grow_forest(xy_train, 99)
	save_obj(rForest, "random_forest2")
	result_rForest = forest_classify(x_test, rForest)
	write_to_csv("result_rForest")

	# get boosted_tree full model
	boosted_tree = grow_booster(xy_train)
	save_obj(boosted_tree, "boosted_tree")
	result_bTree = booster_classify(x_test, boosted_tree[0], boosted_tree[1])
	write_to_csv("result_bTree")

else:
	dTree = load_obj("decision_tree")
	rForest = load_obj("random_forest2")
	adaTree = load_obj("boosted_tree")
