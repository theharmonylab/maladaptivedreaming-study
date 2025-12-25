imm_desc <- textDescriptives(imm_data$pos) # 3.9k posts
md_desc <- textDescriptives(shuffled_mddata$pos) # 28k posts

print(imm_desc, width = Inf)
print(md_desc, width = Inf)
