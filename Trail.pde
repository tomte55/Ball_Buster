class Trail {
  ArrayList<PVector> points = new ArrayList<PVector>();

  void show() {
    push();
    if (points.size() > 1) {
      for (int i = 0; i < points.size(); i++) {
        PVector p1 = points.get(i);
        //PVector p2 = points.get(i+1);
        strokeWeight(constrain(map(i, 0, points.size(), 1, 10), 1, 10));
        stroke(200);
        //line(p1.x, p1.y, p2.x, p2.y);
        point(p1.x, p1.y);
      }
    }
    pop();
  }
}
