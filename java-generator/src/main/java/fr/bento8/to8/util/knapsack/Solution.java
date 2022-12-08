package fr.bento8.to8.util.knapsack;

import java.util.List;

public class Solution {
	
	// list of items to put in the bag to have the maximal value
	public List<Item> items;
	// maximal value possible
	public int value;
	
	public Solution(List<Item> items, int value) {
		this.items = items;
		this.value = value;
	}
	
	public void display() {
		if (items != null  &&  !items.isEmpty()){
			System.out.println("\nKnapsack solution");
			System.out.println("Value = " + value);
			System.out.println("Items to pick :");
			
			for (Item item : items) {
				System.out.println("- " + item.str());
			}
		}
	}

}