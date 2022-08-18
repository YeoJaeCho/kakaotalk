-- 카테고리 별 브랜드  
select *
  from cate_br;

update cate_br
set brand = replace(brand, '(교환권)', '')
where brand like "%(교환권)";
  
-- 많이 선물한 배송상품 top100
select *
  from delivery100;
  
-- 많이 선물한 교환권 카테고리별 top20
select *
  from coupon;

-- 가격대 별 원하는 상품 top20
select *
  from want_present;
  
-- 가격대 별 많이 선물한 상품 top20
select *
  from give_present;

-- 원하는 것을 실제로 준 상품은 ?
select a.brand, a.product_name '원하는 것을 실제로 준 상품', a.price_range '가격대', a.ranking '가격대 별 원하는 상품 순위', b.ranking '가격대 별 많이 준 상품 순위'
  from want_present a, give_present b
  where a.product_name = b.product_name;
  
-- delivery100에 가격대 칼럼을 더미변수 형식으로 추가
select ranking, product_name, price, brand,
       if(price < 10000, 1, 0) '1만원미만',
       if(price >= 10000 and price < 30000, 1, 0) '1_2만원대',
       if(price >= 30000 and price < 50000, 1, 0) '3_4만원대',
       if(price >= 50000, 1, 0) '5만원이상'
  from delivery100;

-- 서브쿼리를 이용해서 delivery100 테이블에서 가격대 별 개수 구하기  
select sum(a.aa) '1만원미만 개수', sum(a.bb) '1_2만원대 개수', sum(a.cc) '3_4만원대 개수', sum(a.dd) '5만원이상 개수'
  from (select ranking, product_name, price, brand,
			   if(price < 10000, 1, 0) aa,
			   if(price >= 10000 and price < 30000, 1, 0) bb,
			   if(price >= 30000 and price < 50000, 1, 0) cc,
			   if(price >= 50000, 1, 0) dd
		  from delivery100
		) a;

-- delivery100 테이블에 가격대 컬럼 추가
select ranking, product_name, price, brand,
   if(price < 10000, '1만원미만', if(price < 30000, '1_2만원대', if(price < 50000, '3_4만원대', '5만원이상'))) price_range
  from delivery100;

-- group by 이용해서 개수 구하기
select a.price_range, count(*)
  from (select ranking, product_name, price, brand,
		   if(price < 10000, '1만원미만', if(price < 30000, '1_2만원대', if(price < 50000, '3_4만원대', '5만원이상'))) price_range
		  from delivery100) a
  group by a.price_range
  order by 2 desc;

-- 많이 선물한 테이블에서 모바일 교환권으로 선물한 것? (많이 선물한 테이블 & 카테고리 join) 보류
select *
  from give_present a
  left join cate_br b
    on a.brand = b.brand
  where b.category is not null;

-- 많이 선물한 교환권은 각 카테고리별로 나와있음
-- 그렇다면 이때 각 카테고리에서 가장 많은 비율을 차지하고 있는 브랜드는?  
with a as (
select b.category cate, b.brand br, count(b.brand) num
  from coupon a
  left join cate_br b
    on a.brand = b.brand
  where b.category is not null
  group by b.category, b.brand
  ),
b as (
select b.category cate, count(b.brand) num
  from coupon a
  left join cate_br b
    on a.brand = b.brand
  where b.category is not null
  group by b.category
  )
select a.cate, a.br, a.num, a.num / b.num * 100 pct
  from a, b
  where a.cate = b.cate;

-- 받고 싶어한 선물 중 카테고리별 최고 브랜드 파악
select a.product_name, a.ranking, b.category, b.brand
  from want_present a
  left join cate_br b
    on a.brand = b.brand
  where b.category is not null;

select cate, br, count(br) num
  from (select a.product_name pro_name, a.ranking ranks, b.category cate, b.brand br
		  from want_present a
		  left join cate_br b
			on a.brand = b.brand
		  where b.category is not null) a
  group by cate, br;

-- 많이 선물한을 많이 선물한 100과 조인, 제품 중 배송상품이 몇 개나 되는지, 몇 순위인지
-- 랭킹 -> 많이 선물한 랭킹 : 최근 거래액이 많은 순
-- 홈 랭킹 : 최근 시간대 별로 선물 수와 급상승 정도  보류
select a.product_name, a.price, b.price_range
	from delivery100 a inner join give_present b on a.product_name = b.product_name;
  
-- 받고 싶어하지만 의외로 많이 선물 안 해주는 품목 
select a.product_name, a.ranking "배송랭킹", b.ranking "위시랭킹", b.price_range, b.ranking - a.ranking "순위차이"
  from delivery100 a 
  inner join want_present b 
    on a.product_name = b.product_name
  order by 3, 5;
 
-- 필승하는 배송상품 선물
select a.product_name, b.ranking, b.price_range
	from delivery100 a 
	inner join want_present b 
		on a.product_name = b.product_name
where b.ranking < 5;

-- 필승하는 교환권 선물
select a.product_name, b.ranking, b.price_range
	from coupon a 
	inner join want_present b 
		on a.product_name = b.product_name
where b.ranking < 5
order by 3;

-- delivery100에서 가장 많이 차지하는 브랜드는?
select brand, count(*)
  from delivery100
  group by brand
  order by 2 desc; 
  
-- coupon에서 가장 많이 차지하는 브랜드
select brand, count(*)
  from coupon
  group by 1
  order by 2 desc;
  
