<%@page import="com.dinero.model.ProductBase64Dao"%>
<%@page import="com.dinero.model.CartBean"%>
<%@page import="com.dinero.model.CartItemBean,java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>cartOutcomepage</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css"
	rel="stylesheet"
	integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3"
	crossorigin="anonymous">
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"
	integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p"
	crossorigin="anonymous"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"
	integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4="
	crossorigin="anonymous"></script>
<script>
    $(function(){
        
        var domainName = '/dinero';

        function fetchAllCouponOfUser(){

            $("#couponTableDiv").empty();

            $.ajax({
                type: "GET",
                url: domainName+'/shop/allcoupon',
                dataType:'json',
                success:function(returnData){
                    //console.log(returnData)

                    if(returnData.length === 0){
                        $("#getCouponbtn").after("<h2>無優惠券可套用</h2>")
                        return;
                    }



                    couponTableContent = "<div id='thisdiv'><table class='table table-bordered' id='thistable'><tr><th>套用</th><th>名稱</th><th>優惠碼</th><th>同時套用</th></tr>";

   
                    var tfToCn = '';

                    $.each(returnData, function(index, element){

                        
                        //console.log(typeof element.concurrency)
                        if(element.concurrency === true){
                            tfToCn = '能';
                        }else if(element.concurrency == false){
                            tfToCn = '否';
                        }

                        var row = '<tr><td> <input type="checkbox" name="selectedcoupon" value="'+element.couponId+'"/> </td>'+
                            '<td>'+ element.couponName+'</td><td>'+element.couponCode+'</td><td>'+tfToCn+'</td></tr></div>';
                        couponTableContent += row;
                        
                    } );
                   
                    couponTableContent += "</table> ";
                    $("#couponTableDiv").append(couponTableContent);
                    $("#thisdiv").append("<button type='button' id='sendSelectedCoupon'class='btn btn-info'>套用</button>")
                    

                },
                error:function(){
                    $("#getCouponbtn").after("<h2>獲取優惠券失敗</h2>")
                }
        })}

      
        

        function sendCouponsToServers(){
            $("#applyreturntable").remove();
            
            //get element of checked ckeckbox
            //console.log($(":checkbox:checked").toArray());
            var checkeElement = $(":checkbox:checked");
            var checkIntArray = [];
            //console.log(checkeElement)
            $.each(checkeElement,function(index, element){
                var newNum = parseInt($(this).prop("value"));
                checkIntArray.push(newNum);
            })

            $.ajax({
                url:domainName+'/shop/applycoupon',
                type:'POST',
                dataType: "json",
        	    contentType: "application/json",
                data:JSON.stringify(checkIntArray),
                success:function(returnData){
                    //console.log(returnData)// return Data 是可套用或不可套用的List 最後含布林值

                    let whereIsBoolean  =returnData.length - 1;
                    let canApplyOrNot  = returnData[whereIsBoolean];
                    var tfToCn = '';
                    

                    if(canApplyOrNot){
						let hiddenInputHtml =''
                        let tableHtml = '<table class="table table-bordered" id="applyreturntable"><caption>可套用</caption><tr><th>名稱</th><th>優惠碼</th><th>優惠單位</th><th>優惠額度</th></tr>';
                            for(let i = 0;i<whereIsBoolean;i++){
                                let thisCoupon= returnData[i];
                                hiddenInputHtml += '<input type="hidden" name="usedcouponsid" value="'+thisCoupon.couponId+'"/>';
                                tableHtml += '<td>'+ thisCoupon.couponName+'</td><td>'+thisCoupon.couponCode+'</td><td>'+thisCoupon.discountUnit+'</td><td>'+thisCoupon.discountValue+'</td></tr>'
                            }
                            tableHtml += '</table>';
                            $("#sendSelectedCoupon").after(tableHtml);

                            returnData.pop();
                            console.log(returnData)

                            $.ajax({
                                url:domainName+'/shop/applysuccesscoupon',
                                type:'POST',
                                dataType:'json',
                                contentType:'application/json',
                                data: JSON.stringify(returnData),
                                success:function(thenextreturndata){

									let sum = parseInt($("#sum").html());
									let discountInt = parseInt(thenextreturndata);
									let newTotal = sum - discountInt;
									
									let appendedRows = "<tr><td  colspan='3'>本次優惠金額為</td><td id='totaldiscountvaluefrontend'>"+thenextreturndata+"</td></tr>" 
									+ "<tr><td  colspan='3'>優惠後總價</td><td >"+ newTotal +"</td></tr>"
									+'<tr><td colspan="4" >'
									+'<form action="'+ domainName+'/shop/couponcheckout" method="post"><input type="hidden" name="discountedTotal" value="'+newTotal+'">'
									+ hiddenInputHtml
									+'<input type="submit" value="優惠結帳" class="btn btn-success" /></td></tr>';

									$("#applyreturntable").append(appendedRows);
									
                                }
                            })
                    }else if(!canApplyOrNot){
                        let tableHtml = '<table class="table table-bordered" id="applyreturntable"><caption>不可套用</caption><tr><th>名稱</th><th>優惠碼</th><th>同時套用</th></tr>';
                        for(let i = 0;i<whereIsBoolean;i++){

                            let thisCoupon= returnData[i];

                            if(thisCoupon.concurrency === true){
                                tfToCn = '能';
                            }else if(thisCoupon.concurrency == false){
                                tfToCn = '否';
                            }

                            console.log(thisCoupon)
                            
                            tableHtml += '<td>'+ thisCoupon.couponName+'</td><td>'+thisCoupon.couponCode+'</td><td>'+tfToCn+'</td></tr>'
                        }
                        tableHtml += '</table>';
                        $("#sendSelectedCoupon").after(tableHtml);
                    }

                }
            })
            
        }


        $("#getCouponbtn").on("click",fetchAllCouponOfUser)
        $(document).on("click","#sendSelectedCoupon",sendCouponsToServers)
       

    })
</script>
</head>
<style>
.picBoundary {
	width: 80%; <!--
	border-style: dashed; --> <!--
	border-width: 0.2em; -->
	height: 80%;
}

img {
	max-width: 100%;
	max-height: 100%;
}

tr {
	vertical-align: middle;
	text-align: center;
}
.widthControll{
	width:20%;
}
</style>
<body>
	
	<jsp:include page="navbar.jsp"></jsp:include>
	<jsp:useBean id="cartDto" class="com.dinero.model.CartBean" scope="session"></jsp:useBean>
	<div class="container">
		<table class="table table-bordered">
			<thead>
				<tr>
					<th></th>
					<th>商品id</th>
					<th class="widthControll">圖片</th>
					<th>價格</th>
					<th >數量</th>
					<th>金額</th>
					<th>修改</th>
					<th>刪除</th>
				</tr>
			</thead>
			<tbody>
				<%
				List<CartItemBean> items = cartDto.getItems();
				items.forEach(System.out::println);

				int tmpCartTotal = 0;
				int tmpOneItemTotal;

				int tmpItemId = 0;
				
				//使用base 64顯示圖片
				ProductBase64Dao p64dao = (ProductBase64Dao)session.getAttribute("p64dao");
				
				for (CartItemBean item : items) {
					tmpItemId++;
				%>
				<tr>
					<td><input type="checkbox"><%=tmpItemId%></td>
					<td><%=item.getProduct().getProdId()%></td>
					<td class="widthControll"><div class="picBoundary">
							<img src="<%=item.getProduct().getProdImg()%>" />
						</div></td>
					<td><%=item.getPrice()%></td>
					<td >
						<form action="<%=request.getContextPath() %>/shop/editItemFromCart" method="post">
							<input type="hidden" name="toDo" value="edit"> <input
								type="hidden" name="prodId" value="<%=item.getProduct().getProdId()%>">
							<input type="hidden" name="index" value="<%=tmpItemId - 1%>" /> <input
								type="text" name="newQty" value="<%=item.getQty()%>" size="6"/>
						</form>
					</td>
					<td><%=item.getItemTotal()%></td>
					<%
					tmpOneItemTotal = item.getItemTotal();
					tmpCartTotal += tmpOneItemTotal;
					%>

					<!-- 編輯商品數量 -->
					<td><a href="<%=request.getContextPath() %>/gewei/EditItem.jsp?index=<%=tmpItemId - 1%>"
						class="btn btn-primary">編輯</a></td>
					<td>
						<form action="<%=request.getContextPath() %>/shop/deleteItemFromCart" method="post">
							<input type="hidden" name="index" value="<%=tmpItemId - 1%>">
							 <input
								type="submit" value="刪除" class="btn btn-danger" />
						</form>
					</td>
				</tr>
				<%
				}
				%>
				<jsp:setProperty property="cartTotal" name="cartDto"
					value="<%=tmpCartTotal%>" />

				<tr>
					<td colspan="5">總額</td>
					<td id="sum"><jsp:getProperty property="cartTotal"
							name="cartDto" /></td>
					<td>
						<button type="button" class="btn btn-success"
							data-bs-toggle="modal" data-bs-target="#exampleModal"
							data-bs-whatever="@mdo">結帳</button>
					</td>
					<td>
						<form action="<%=request.getContextPath() %>/shop/clearCart" method="post">

							 <input
								type="submit" value="清空" class="btn btn-danger" />
						</form>
					</td>
				</tr>
			</tbody>
		</table>

		<%-- 結帳彈跳 --%>
		<div class="modal fade" id="exampleModal" tabindex="-1"
			aria-labelledby="exampleModalLabel" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title" id="exampleModalLabel">確認付款</h5>
						<button type="button" class="btn-close" data-bs-dismiss="modal"
							aria-label="Close"></button>
					</div>
					<div class="modal-body">
						<table class="table table-bordered">
							<thead>
								<tr>

									<th>商品id</th>
									<th>價格</th>
									<th>數量</th>
									<th>金額</th>
								</tr>
							</thead>
							<tbody>
								<%
								for (CartItemBean item : items) {
									tmpItemId++;
								%>
								<tr>
									<td><%=item.getProduct().getProdId()%></td>
									<td><%=item.getPrice()%></td>
									<td><%=item.getQty()%></td>
									<td><%=item.getItemTotal()%></td>
								</tr>
								<%
								}
								%>
								<tr>
									<td><button id="getCouponbtn" class="btn btn-info">優惠券</button></td>
									<td colspan="2">總額</td>
									<td id="sum"><jsp:getProperty property="cartTotal"
											name="cartDto" /></td>


								</tr>
							</tbody>
						</table>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-secondary"
							data-bs-dismiss="modal">回前頁</button>

						<form action="<%=request.getContextPath() %>/shop/checkoutAndWriteToDb" method="post">

							<input type="submit" value="結帳" class="btn btn-success" />
						</form>
					</div>
					<div id="couponTableDiv" class="modal-body"></div>
				</div>
			</div>
		</div>
		<!-- 結帳彈跳結束 -->
	</div>
	<script>
		let sumTdRow = document.getElementById("sum");
		let sum = sumTdRow.innerHTML;
	</script>
	
</body>
</html>