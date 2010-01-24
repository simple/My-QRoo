require 'rubygems'
require 'sinatra'
require 'qroo'

include Qroo
before do
  headers "Content-Type" => "text/html; charset=utf-8"
end
get '/' do
  @title = "My-QRoo, Login Information"
  erb :form
end

post '/' do
  @title = "Your QRooQRoo barcode scan history"
  
  client = QrooClient.new(params[:loginid], @params[:password])
  products = client.get_products
  @books = products.collect do |product|
    if !product['BOOK'].nil? and product['BOOK'].size == 1
      product['BOOK'][0]
    end
  end
    
  erb :result
end

__END__

@@ layout
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<title><%= @title %></title>
</head>
<body>
<%= yield %>
</body>
</html>

@@ result
<h3>You have scanned <%= @books.size %> books!</h3>
<table>
  <tr><td>Title</td><td>Author</td><td>ISBN</td><td>Category</td></tr>
<% @books.each do |book| %>
  <tr>
    <td><%= book['TITLE'] %></td><td><%= book['AUTHOR'] %></td>
    <td><%= book['ISBN'] %></td><td><%= book['CATEGORY'] %></td></tr>
<% end %>
</table>

@@ form
<h3>QRooQRoo Login Information</h3>
<p>
Test interface for QRooQRoo client. Intended to be used for personal use only.
</p>
<form action="/" method="post">
  ID: <input type="text" name="loginid" size="20"/><br/>
  Password: <input type="text" name="password" size="20"/><br/>
  <input type="submit" value="Let me show you"/>
</form>
