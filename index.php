<html>
<head><meta http-equiv="refresh" content="3"></head>
<style>p {font-size: 36;}</style>
<body>
<?php 
    $localdb = $db_file = new PDO('sqlite:results.s3db');
    $select = "Select * From PerformanceStats Order By timestamp Desc Limit 1";
    $stmt = $localdb->prepare($select);
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC)[0];
    echo "<p>";
    echo "<b>CPU:</b> " . $results["cpu"] . " <b>GPU:</b> " . $results["gpu"] . "<br /> <b>Memory Free:</b> " . $results["memoryfree"] ;
    echo "<br /> <b>GPU Memory Used:</b> " . $results["GPUMemoryUsed"] ;
    echo "<br /> <b>routerping:</b> " . $results["routerping"] ;
    echo "<br /> <b>Internet Ping:</b> " . $results["googleping"]  ;
    echo "</p>";
    echo "PHP Memory usage: " . (int)(memory_get_usage() / 1024) . "kb";
?>


</body>