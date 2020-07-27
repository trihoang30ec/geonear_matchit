* global gis "D:\Depocen\database\GIS data\VNM_adm"
cd "D:\Depocen\Depocen project\2019\thuoc la-nuong"
*____________________________Tao bien dia ban (gps)_____________________________*
use "thong-tin-cua-hang [2018]", clear
*_________________Giai doan 1: Ghep theo ten va dia chi cua hang________________*
* ssc install geonear
* ssc install matchit
geonear _index_shop18 _a5a_latitude18 _a5a_longitude18 using "thong-tin-cua-hang [2019]", ///
n(_index_shop19 _a5a_latitude19 _a5a_longitude19) long limit(10) nearcount(1) within(2) miles // within (2) miles and request at least one (1) nearest neighbor
* moi cua hang 2018 duoc ghep toi da voi 10 cua hang 2019 (trong ban kinh 2 miles)
* convert mile to meter
gen met_to__index_shop19 = mi_to__index_shop19*1609.344
sort _index_shop19
merge m:1 _index_shop19 using "thong-tin-cua-hang [2019]" // lay thong tin ve ten va dia chi cua hang
keep if _merge == 3
drop _merge
sort _index_shop18
merge m:1 _index_shop18 using "thong-tin-cua-hang [2018]" // lay thong tin ve ten va dia chi cua hang
bys _index_shop18 (met_to__index_shop19) : gen duplicate = _n
drop _merge

matchit a319 a318, sim(token) g(match_name) // tao bien "similarity score" cua ten cua hang, thuoc khoang [0, 1]
matchit a519 a518, sim(token) g(match_add) // tao bien "similarity score" cua dia chi cua hang, thuoc khoang [0, 1]
*gen match_name_valid = (match_name > 0.7)
* gen match_add_valid = (match_add > 0.7)

* Similarity level
gen cap1 = (match_name > 0.5 & match_add > 0.5) // level 1
gen cap2 = (match_name > 0.3 & match_add > 0.3 & cap1 == 0) // level 2
bys _index_shop19 aa: gen d3 = _n
keep if d3 == 1
gen cap3 = (cap1 == 0 & cap2 == 0 & aa == 1) // level 3: check lai cua hang 2019 duoc ghi nhan la "khao sat dau ky" nhung similarity score rat thap
gen cap4 = (cap1 == 0 & cap2 == 0 & cap3 == 0) // level 4: nhung cua hang con lai

* Ghep cac levels [1] [2] [3] [4] (giai doan 1): "cua-hang-name_add.dta"

*_____________________Giai doan 2: Ghep theo so dien thoai______________________*
* files: "dien-thoai [2018] 2" va "dien-thoai [2019] 2" bao gom danh sach cua hang con lai (chua duoc ghep)
use "dien-thoai [2018] 2", clear
geonear _index_shop18 _a5a_latitude18 _a5a_longitude18 using "dien-thoai [2019] 2", ///
n(_index_shop19 _a5a_latitude19 _a5a_longitude19) long limit(10) nearcount(1) within(2) miles 
* moi cua hang 2018 duoc ghep toi da voi 10 cua hang 2019 (trong ban kinh 2 miles)
* convert mile to meter
gen met_to__index_shop19 = mi_to__index_shop19*1609.344
sort _index_shop19
merge m:1 _index_shop19 using "dien-thoai [2019] 2"
keep if _merge == 3
drop _merge
sort _index_shop18
merge m:1 _index_shop18 using "dien-thoai [2018] 2"
bys _index_shop18 (met_to__index_shop19) : gen duplicate = _n
drop _merge

tostring a419 a418, replace force
matchit a419 a418, sim(token) g(match_phone)
keep if match_phone == 1 & a419 != "-99"  // level 5: ghep theo so dien thoai

* Ghep cac levels [1] [2] [3] [4] [5] (giai doan 1 + 2): "cua-hang-name_add_phone" danh sach 148 cua hang duoc ghep

*_______________________Giai doan 3: Cac cua hang con lai_______________________*
* "thong-tin-cua-hang [2018] 2" va "thong-tin-cua-hang [2019] 2": danh sach cac cua hang con lai chua duoc ghep
use "thong-tin-cua-hang [2018] 2", clear
geonear _index_shop18 _a5a_latitude18 _a5a_longitude18 using "thong-tin-cua-hang [2019] 2", ///
n(_index_shop19 _a5a_latitude19 _a5a_longitude19) long limit(10) nearcount(1) within(2) miles 
* convert mile to meter
gen met_to__index_shop19 = mi_to__index_shop19*1609.344
sort _index_shop19
merge m:1 _index_shop19 using "thong-tin-cua-hang [2019] 2"
keep if _merge == 3
drop _merge
sort _index_shop18
merge m:1 _index_shop18 using "thong-tin-cua-hang [2018] 2"
bys _index_shop18 (met_to__index_shop19) : gen duplicate = _n
drop _merge

matchit a319 a318, sim(token) g(match_name) 
matchit a519 a518, sim(token) g(match_add) 
gen match_name_valid = (match_name >= 0.5) // Check nhung cua hang giong ten
gen match_add_valid = (match_add >= 0.5) // Check nhung cua hang giong dia chi


