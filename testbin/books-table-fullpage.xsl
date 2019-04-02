<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
<html>
  <head>
    <title>Каталог домашних книг для избавления от них</title>
    <script type="text/javascript" src="jquery-1.4.2.min.js"></script>
    <script type="text/javascript">
      $(document).ready(function() {
//	$('#catalog').tableSearch();
//	$('#catalog').dataTable({"sPaginationType": "full_numbers"});
	$('#catalog').flexigrid();
      } );
    </script>
    <style type="text/css" title="currentStyle">
			table td {
			  border: 1px solid green;
				}
    </style>
  </head>
  <body>
    <table id="catalog">
      <caption>Книги на избавление</caption>
      <thead>
	<tr>
	  <th>Изображение</th>
	  <th>Название</th>
	  <th>Автор</th>
	  <th>Издательство</th>
	  <th>Город</th>
	  <th>Год</th>
	  <th>Описание</th>
	  <th>Количество страниц</th>
	  <th>Состояние</th>
	</tr>
      </thead>
      <tbody>
	<xsl:for-each select="books/book">
	  <tr>
	    <td class="image"><xsl:apply-templates select="image" /></td>
	    <td class="name"><xsl:apply-templates select="name" /></td>
	    <td><xsl:apply-templates select="author" /></td>
	    <td><xsl:apply-templates select="publisher" /></td>
	    <td><xsl:apply-templates select="city" /></td>
	    <td><xsl:apply-templates select="year" /></td>
	    <td class="descr"><xsl:apply-templates select="description" /></td>
	    <td><xsl:apply-templates select="pagenum" /></td>
	    <td><xsl:apply-templates select="condition" /></td>
	  </tr>
	</xsl:for-each>
      </tbody>
    </table>
  </body>
</html>
</xsl:template>

<xsl:template match="image">
  <a><xsl:attribute name="href">images/<xsl:value-of select="." /></xsl:attribute><img><xsl:attribute name="src">images/thumbs/thumb-<xsl:value-of select="." /></xsl:attribute></img></a>
</xsl:template>

<xsl:template match="name | author | publisher | city | pagenum | condition | year | description">
  <xsl:value-of select="." />
</xsl:template>

</xsl:stylesheet>

