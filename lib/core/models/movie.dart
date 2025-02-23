class Movie {
  final String title;
  final String year;
  final String imageUrl;
  final String? description;

  const Movie({
    required this.title,
    required this.year,
    required this.imageUrl,
    this.description,
  });
}

// Mock data
final List<Movie> mockMovies = [
  const Movie(
    title: 'Inception',
    year: '2010',
    imageUrl: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
  ),
  const Movie(
    title: 'The Grand Budapest Hotel',
    year: '2014',
    imageUrl: 'https://image.tmdb.org/t/p/w500/eWdyYQreja6JGCzqHWXpWHDrrPo.jpg',
  ),
  const Movie(
    title: 'Interstellar',
    year: '2014',
    imageUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
  ),
  const Movie(
    title: 'Joker',
    year: '2019',
    imageUrl: 'https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg',
  ),
  const Movie(
    title: 'Dune',
    year: '2021',
    imageUrl: 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
  ),
  const Movie(
    title: 'Blade Runner 2049',
    year: '2017',
    imageUrl: 'https://image.tmdb.org/t/p/w500/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
  ),
];
