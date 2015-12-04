awk '{if (NR==2) { sub(/[0-9]+/, $3 + 1, $3) } }1' cache.appcache > temp; cat temp > cache.appcache && rm temp
