#!/usr/bin/env ruby
require 'net/http'
require 'rubygems'
require 'xmlsimple'

module Qroo
  class QrooClient
    ProductsPerPage = 12
    def get_products()
      current_page = 1
      is_last_page = false
      products = []
      while is_last_page == false
        barcodes = get_scanned_barcords(current_page)
        current_page += 1
        is_last_page = true if barcodes.size < ProductsPerPage
        #puts "got #{barcodes.size} products from page #{current_page}"
        products |= fetch_products_info(barcodes)
      end
      products
    end
    def fetch_products_info(barcodes)
      products = []
      barcodes.each do |barcode|
        products << get_product_info(barcode[0])
      end
      products
    end
    def get_product_info(barcode)
      info_path = '/m/viewProductInfo.do?barcode=' + barcode
      xml = Net::HTTP.get_response('qrooqroo.com', info_path).body
      data = XmlSimple.xml_in(xml)
    end
    def get_scanned_barcords(page = 1)
      path = "/viewScanHistory.do?qrCode.codeType=01&currentPage=#{page}"
      #puts "getting document: #{path}"
      barcodes = get_document(path).scan(/"bacode_num">(\d+)</)
    end
    def get_document(path)
      @http.request_get(path, @header).body
    end
  
    def initialize(id, password)
      @http = Net::HTTP.new('qrooqroo.com', 80)
      renew_session
      login(id, password)
    end
  
    def renew_session()
      session = Net::HTTP.get_response('qrooqroo.com', '/home.do').
                        header['Set-Cookie'].
                        split(';')[0]
      @header = { 'Cookie' => session }
    end

    def login(id, password)
      data = 'member.memId=' + id + '&member.password=' + password
      @http.request_post('/memberLogin.do', data, @header)
    end
  end
end

if $0 == __FILE__
  loginid = password = ''
  loginid = ARGV[0] if ARGV[0]
  password = ARGV[1] if ARGV[1]
  
  client = QrooClient.new(loginid, password)
  products = client.get_products
  books = products.collect do |product|
    if !product['BOOK'].nil? and product['BOOK'].size == 1
      product['BOOK'][0]
    end
  end
  puts "You've scanned #{books.size} books!"
  books.each do |book|
    puts "title: #{book['TITLE']}, ISBN: #{book['ISBN']}"
    # "PUBDATE","AUTHOR","ISBN","COVERIMG","TITLE","TRANSLATOR","PUBNM","CATEGORY"
  end
end

__END__
# sample book_xml object
book_xml = {
  "REQCNT"=>["."], "KIND"=>["."], 
  "BARCODE"=>["9788996241003"], 
  "DAUMAPIKEY"=>["."], "ORIGIN"=>["."], 
  "BOOKITEM"=>[
    {
      "PRICE"=>["18000"],
      "NAME"=>["서버/인프라를 지탱하는 기술"],
      "IMAGE"=>["http://www.noranbook.net/images/common/noimage.gif"],
      "BARCODE"=>["9788996241003"],
      "LINK"=>["http://ad.noranbook.net/noran_track.asp?spmidx=8&isbn=8996241008&url=http%3A%2F%2Fbook%2Einterpark%2Ecom%2Fproduct%2FBookDisplay%2Edo%3F%5Fmethod%3Ddetail%26sc%2EshopNo%3D0000400000%26sc%2EdispNo%3D024918001%26sc%2EprdNo%3D202156197&murl=http%3A%2F%2Fbook%2Einterpark%2Ecom%2Fgate%2Fippgw%2Ejsp%3Fbiz%5Fcd%3DP12951%26url%3D"],
      "MALLIMAGE"=>["../../images/webView/logo/book_interpark.png"],
      "MALL"=>["인터파크도서"]
    }, {
      "PRICE"=>["18560"], 
      "NAME"=>["서버/인프라를 지탱하는 기술"],
      "IMAGE"=>["http://image3.kangcom.com/2009/04/l_pic/200904140003.jpg"],
      "BARCODE"=>["9788996241003"],
      "LINK"=>["http://ad.noranbook.net/noran_track.asp?spmidx=11&isbn=8996241008&url=http%3A%2F%2Fkangcom%2Ecom%2Fsub%2Fview%2Easp%3Fsku%3D200904140003%26partnerid%3Dnoranbook"],
      "MALLIMAGE"=>["../../images/webView/logo/book_kangcom.png"],
      "MALL"=>["강컴"]
    }, {
      "PRICE"=>["19000"],
      "NAME"=>["24시간 365일 서버/인프라를 지탱하는 기술"],
      "IMAGE"=>["http://image.book.11st.co.kr/imgprd/1/2009/04/23/db2/M0000000592994_106x145.png"],
      "BARCODE"=>["9788996241003"],
      "LINK"=>["http://ad.noranbook.net/noran_track.asp?spmidx=13&isbn=8996241008&url=http%3A%2F%2Fbook%2E11st%2Eco%2Ekr%2FAffiliate%2Edo%3Fcmd%3Dgateway%26PARTNER%5FCD%3D2521%26gdsNo%3DM0000000592994&murl=http%3A%2F%2Fbook%2E11st%2Eco%2Ekr%2FAffiliate%2Edo%3Fcmd%3Dgateway%26PARTNER%5FCD%3D2521%26returnUrl%3D"],
      "MALLIMAGE"=>["../../images/webView/logo/book_11st.png"],
      "MALL"=>["도서11번가"]
    }, {
      "PRICE"=>["20250"],
      "NAME"=>["서버/인프라를 지탱하는 기술"],
      "IMAGE"=>["http://image.aladdin.co.kr/coveretc/book/coversum/8996241008_1.jpg"],
      "BARCODE"=>["9788996241003"],
      "LINK"=>["http://ad.noranbook.net/noran_track.asp?spmidx=2&isbn=8996241008&url=http%3A%2F%2Fwww%2Ealaddin%2Eco%2Ekr%2Fshop%2Fwproduct%2Easpx%3FISBN%3D8996241008"],
      "MALLIMAGE"=>["../../images/webView/logo/book_aladdin.png"],
      "MALL"=>["알라딘"]
    },{
      "PRICE"=>["20250"],
      "NAME"=>["서버 인프라를 지탱하는 기술"],
      "IMAGE"=>["http://image.kyobobook.co.kr/images/book/medium/003/m9788996241003.jpg"],
      "BARCODE"=>["9788996241003"],
      "LINK"=>["http://ad.noranbook.net/noran_track.asp?spmidx=7&isbn=8996241008&url=http%3A%2F%2Fwww%2Ekyobobook%2Eco%2Ekr%2Fproduct%2FdetailViewKor%2Elaf%3FmallGb%3DKOR%26ejkGb%3DKOR%26linkClass%3D%26barcode%3D9788996241003&murl=http%3A%2F%2Fwww%2Ekyobobook%2Eco%2Ekr%2Fcooper%2Fredirect%5Fover%2Ejsp%3FLINK%3DNRB%26next%5Furl%3D"],
      "MALLIMAGE"=>["../../images/webView/logo/book_kyobo.png"],
      "MALL"=>["교보문고"]
    }, {
      "PRICE"=>["20250"],
      "NAME"=>["24시간 365일 서버/인프라를 지탱하는 기술"],
      "IMAGE"=>["http://image.yes24.com/momo/TopCate72/MidCate10/7191033.jpg"],
      "BARCODE"=>["9788996241003"],
      "LINK"=>["http://ad.noranbook.net/noran_track.asp?spmidx=1&isbn=8996241008&url=http%3A%2F%2Fwww%2Eyes24%2Ecom%2F24%2Fgoods%2F3377489&murl=http%3A%2F%2Fwww%2Eilikeclick%2Ecom%2Ftracking%2Fclick%2FSpecial%5FClick%2Ephp%3FAID%3Djeonmy%26dts%5Fcode%3D100372870020109539000013315100000000000%26turl%3D"],
      "MALLIMAGE"=>["../../images/webView/logo/book_yes24.png"],
      "MALL"=>["예스24"]
    }, {
      "PRICE"=>["20250"],
      "NAME"=>["서버/인프라를지탱하는기술(24시간365일)"],
      "IMAGE"=>["http://222.106.174.37/upload/img/book/121/100007121.jpg"],
      "BARCODE"=>["9788996241003"],
      "LINK"=>["http://ad.noranbook.net/noran_track.asp?spmidx=12&isbn=8996241008&url=http%3A%2F%2Fwww%2Eypbooks%2Eco%2Ekr%2Fbook%2Eyp%3Fbookcd%3D100007121%26gubun%3DYE"],
      "MALLIMAGE"=>["../../images/webView/logo/book_ypbooks.png"],
      "MALL"=>["영풍문고"]
    }, {
      "PRICE"=>["21780"],
      "NAME"=>["서버 인프라를 지탱하는 기술"],
      "IMAGE"=>["http://image.bandinlunis.com/upload/product/2972/2972749_s.jpg"],
      "BARCODE"=>["9788996241003"],
      "LINK"=>["http://ad.noranbook.net/noran_track.asp?spmidx=6&isbn=8996241008&url=http%3A%2F%2Fwww%2Ebandinlunis%2Ecom%2Ffront%2Fpartner%2Edo%3Fpartner%3D112%26url%3D%2Ffront%2Fproduct%2FdetailProduct%2Edo%3FprodId%3D2972749&murl=http%3A%2F%2Fclick%2Elinkprice%2Ecom%2Fclick%2Ephp%3Fm%3Dbandibook%26a%3DA100206272%26l%3D9999%26l%5Fcd1%3D3%26l%5Fcd2%3D0%26tu%3D"],
      "MALLIMAGE"=>["../../images/webView/logo/book_bandi.png"],
      "MALL"=>["반디앤루니스"]
    }, {
      "PRICE"=>["22000"],
      "NAME"=>["서버 인프라를 지탱하는 기술[배송료 : 2500]"],
      "IMAGE"=>["http://gdimg4.gmarket.co.kr/goods_image2/small_img/165/900/165900022.jpg"],
      "BARCODE"=>["9788996241003"],
      "LINK"=>["http://ad.noranbook.net/noran_track.asp?spmidx=24&isbn=8996241008&url=http%3A%2F%2Fwww%2Egmarket%2Eco%2Ekr%2Fchallenge%2Fneo%5Fjaehu%2Fjaehu%5Fgoods%5Fgate%2Easp%3Fgoodscode%3D165900022%26GoodsSale%3DY"],
      "MALLIMAGE"=>["../../images/webView/logo/book_gmarket.png"],
      "MALL"=>["G마켓"]
    }
  ],
  "DESCRIPTION"=>["."],
  "COMPANYNAME"=>["."],
  "PRODUCTNAME"=>["."],
  "BOOK"=>[
    {
      "PUBDATE"=>["2009. 4. 22."],
      "AUTHOR"=>["이토 나오야"],
      "ISBN"=>["9788996241003"],
      "COVERIMG"=>["http://bookimg.daum.net/R72x100/KOR9788996241003"],
      "TITLE"=>["서버 인프라를 지탱하는 기술"],
      "TRANSLATOR"=>["진명조"],
      "PUBNM"=>["제이펍"],
      "CATEGORY"=>["컴퓨터/IT "]
    }
  ]
}
