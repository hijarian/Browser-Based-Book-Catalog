<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' >
<xsl:output method='html' version='1.0' encoding='UTF-8' indent='yes' />
<xsl:param name="show-images" select="1" />
<xsl:param name="category" select="'Детективы'" />
<xsl:param name="selector-mode" select="'all'" />
  <xsl:template match="/">
<html>
  <head>
    <title>Каталог домашних книг для избавления от них</title>
    <script type="text/javascript" src="jquery-1.4.2.min.js"></script>
    <script type="text/javascript">
      $(document).ready(function() {
	$('#catalog').dataTable({"sPaginationType": "full_numbers"});
      } );
    </script>
    <style type="text/css" title="currentStyle">
			table td {
			  border: 1px solid green;
				}
    </style>
  </head>
  <body>
    <table id='catalog'>
			<caption>Книги на избавление: <xsl:value-of select="$category" />. Selector mode: <xsl:value-of select="$selector-mode" /></caption>
      <thead>
				<tr>
					<xsl:if test="$selector-mode='all'">
						<th>Категория</th>
					</xsl:if>
					<xsl:if test="$show-images">
						<th>Изображение</th>
					</xsl:if>
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
		<xsl:choose>
			<xsl:when test='$selector-mode="all"'>
				<xsl:apply-templates select="books/book" />
			</xsl:when>
			<xsl:when test='$selector-mode="category"'>
				<xsl:apply-templates select="books/book[@category=$category]" />
			</xsl:when>
			<xsl:when test='$selector-mode="undef"'>
				<xsl:apply-templates select="books/book[not(@category)]" />
			</xsl:when>
		</xsl:choose>
      </tbody>
    </table>
  </body>
</html>
  </xsl:template>

	<xsl:template match="book">
		<tr>
		<xsl:if test='$selector-mode="all"'>
			<td class="category"><xsl:apply-templates select="@category" /></td>
		</xsl:if>
		<xsl:if test="$show-images">
			<td class="image"><xsl:apply-templates select="image" /></td>
		</xsl:if>
			<td class="name"><xsl:apply-templates select="name" /></td>
			<td><xsl:apply-templates select="author" /></td>
			<td><xsl:apply-templates select="publisher" /></td>
			<td><xsl:apply-templates select="city" /></td>
			<td><xsl:apply-templates select="year" /></td>
			<td class="descr"><xsl:apply-templates select="description" /></td>
			<td><xsl:apply-templates select="pagenum" /></td>
			<td><xsl:apply-templates select="condition" /></td>
		</tr>
	</xsl:template>

<xsl:template match="image">
  <a><xsl:attribute name="href">data/images/<xsl:value-of select="." /></xsl:attribute><img><xsl:attribute name="src">data/thumbnails/thumb-<xsl:value-of select="." /></xsl:attribute></img></a>
</xsl:template>

<xsl:template match="name | author | publisher | city | pagenum | condition | year | description">
  <xsl:value-of select="." />
</xsl:template>

<xsl:template match="@category">
  <xsl:value-of select="." />
</xsl:template>

</xsl:stylesheet>

