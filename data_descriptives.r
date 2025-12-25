library("rstatix")

imm_desc <- textDescriptives(imm_data$pos) # 3.9k posts
md_desc <- textDescriptives(shuffled_mddata$pos) # 28k posts

print(imm_desc, width = Inf)
print(md_desc, width = Inf)

# Calculate and print valence t-test for categories of subreddit
valence_ttest <- t.test(Valence ~ Subreddit, data = combined_dataset)
print("Valence t-test between subreddits")
print(valence_ttest)

combined_dataset %>% cohens_d(Valence ~ Subreddit, var.equal = FALSE)
