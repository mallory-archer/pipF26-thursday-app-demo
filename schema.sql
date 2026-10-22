-- Class survey load for class_dataset.csv.
-- Rebuilds these tables and reloads all 23 responses.
-- ./deploy.sh applies this file to Railway Postgres. Running that script is a separate step.
-- netid: values starting with N are kept as submitted;
-- emails become the lowercased part before @; everything else is lowercased.
-- Avirul Islam's working_style was the Excel error #NAME? and is stored as null.

BEGIN;

DROP TABLE IF EXISTS student_availability;
DROP TABLE IF EXISTS student_tools;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS availability_slots;
DROP TABLE IF EXISTS tools;

CREATE TABLE students (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    netid text NOT NULL UNIQUE,
    full_name text NOT NULL,
    school_year text NOT NULL CHECK (school_year IN ('First-year', 'Sophomore', 'Junior', 'Senior')),
    intro_programming text NOT NULL CHECK (intro_programming IN ('took_it', 'equivalent', 'neither')),
    skill_programming smallint NOT NULL CHECK (skill_programming BETWEEN 1 AND 5),
    skill_data_stats smallint NOT NULL CHECK (skill_data_stats BETWEEN 1 AND 5),
    skill_frontend_design smallint NOT NULL CHECK (skill_frontend_design BETWEEN 1 AND 5),
    skill_business_pitch smallint NOT NULL CHECK (skill_business_pitch BETWEEN 1 AND 5),
    working_style text,
    interests text NOT NULL,
    semester_goal text NOT NULL,
    submitted_at timestamptz NOT NULL
);

CREATE TABLE tools (
    id smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE student_tools (
    student_id bigint NOT NULL REFERENCES students (id) ON DELETE CASCADE,
    tool_id smallint NOT NULL REFERENCES tools (id),
    PRIMARY KEY (student_id, tool_id)
);

CREATE INDEX student_tools_tool_id_idx ON student_tools (tool_id);

CREATE TABLE availability_slots (
    id smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE,
    sort_order smallint NOT NULL UNIQUE
);

CREATE TABLE student_availability (
    student_id bigint NOT NULL REFERENCES students (id) ON DELETE CASCADE,
    slot_id smallint NOT NULL REFERENCES availability_slots (id),
    PRIMARY KEY (student_id, slot_id)
);

CREATE INDEX student_availability_slot_id_idx ON student_availability (slot_id);

INSERT INTO tools (name) VALUES
    ($survey$Python$survey$),
    ($survey$Excel$survey$),
    ($survey$SQL$survey$),
    ($survey$JavaScript$survey$),
    ($survey$R$survey$);

INSERT INTO availability_slots (label, sort_order) VALUES
    ($survey$Weekday mornings$survey$, 1),
    ($survey$Weekday afternoons$survey$, 2),
    ($survey$Weekday evenings$survey$, 3),
    ($survey$Weekend mornings$survey$, 4),
    ($survey$Weekend afternoons$survey$, 5),
    ($survey$Weekend evenings$survey$, 6);

INSERT INTO students (
    netid, full_name, school_year, intro_programming,
    skill_programming, skill_data_stats, skill_frontend_design, skill_business_pitch,
    working_style, interests, semester_goal, submitted_at
) VALUES
    ($survey$jq2306$survey$, $survey$Jin Michael Qian$survey$, $survey$Senior$survey$, $survey$took_it$survey$, 3, 4, 2, 5, $survey$I’m good at multitasking, I can coordinate team events and organize agenda, good at providing ideas$survey$, $survey$City exploring, hiking, poker, gym, mahjong(Japanese), food$survey$, $survey$An app that people actually wanna use as a better replacement for current options$survey$, $survey$2026-09-11T01:47:37+00:00$survey$),
    ($survey$zh2740$survey$, $survey$Edward Huang$survey$, $survey$Senior$survey$, $survey$took_it$survey$, 2, 3, 2, 4, $survey$I prefer direct, concise collaboration with clearly defined responsibilities. I usually prefer to get things done a couple days in advance (just so I can have peace of mind).$survey$, $survey$Watch movies, hang out with friends and family, travel, go on hikes.$survey$, $survey$I hope that we can build an app that properly functions and solves a real problem people have. In the process, I look forward to pick up some vibe coding/development skills.$survey$, $survey$2026-09-11T01:59:42+00:00$survey$),
    ($survey$yo2162$survey$, $survey$Yulong Ou$survey$, $survey$Senior$survey$, $survey$took_it$survey$, 3, 3, 3, 3, $survey$I work best with a clear plan, defined responsibilities, and regular communication. I am comfortable taking ownership of technical tasks, working independently, and letting the team know early when I encounter a problem.$survey$, $survey$Outside class, I enjoy working on AI and computer vision research, building side projects, and mentoring younger students in app development. I also like following technology and finance and exploring New York City.$survey$, $survey$By December, I want to have built a polished end-to-end application that uses real data, includes a reliable data science model, and has a user-friendly interface. I also want to improve at turning an ambitious idea into a manageable product and collaborating effectively through GitHub.$survey$, $survey$2026-09-11T03:15:17+00:00$survey$),
    ($survey$N16059079$survey$, $survey$Maxson Cook$survey$, $survey$Sophomore$survey$, $survey$took_it$survey$, 4, 4, 1, 1, $survey$Efficient and collaborative. I’d rather we discuss a lot and then maybe execute separately but have clear goals and communication.$survey$, $survey$Running
Basketball
Football
Fantasy football
Soccer
Horse racing$survey$, $survey$I want to build out my horse racing project regardless of whether or not I do this with my group or not.$survey$, $survey$2026-09-11T03:15:25+00:00$survey$),
    ($survey$nsc9331$survey$, $survey$Natalie Chen$survey$, $survey$Junior$survey$, $survey$took_it$survey$, 3, 3, 1, 1, $survey$I like to be organized and like to divide roles between members in the group$survey$, $survey$Dance, eating out at restaurants, music, cooking$survey$, $survey$I want to learn how to design things on the frontend$survey$, $survey$2026-09-11T03:23:19+00:00$survey$),
    ($survey$yk2772$survey$, $survey$Solomon Kim$survey$, $survey$Junior$survey$, $survey$took_it$survey$, 5, 5, 5, 4, $survey$I tend to work things before deadline.$survey$, $survey$I like running and playing badminton.$survey$, $survey$How to build and service an idea$survey$, $survey$2026-09-11T13:55:36+00:00$survey$),
    ($survey$ai2278$survey$, $survey$Avirul Islam$survey$, $survey$Senior$survey$, $survey$took_it$survey$, 4, 5, 4, 5, NULL, $survey$Finance, Quant, Tech$survey$, $survey$Built a demo which is presentable and something which I can carry forward.$survey$, $survey$2026-09-11T14:27:14+00:00$survey$),
    ($survey$mr7316$survey$, $survey$Myra Rafiq$survey$, $survey$Junior$survey$, $survey$equivalent$survey$, 3, 4, 2, 4, $survey$I’m pretty Type A and like getting things done ahead of time rather than leaving everything until the last minute. I like being on time, making lists, keeping track of tasks, and knowing what needs to get done.$survey$, $survey$I love trying new cafes, reading thriller novels, poetry, and spending time with friends. I’m also really interested in startups, AI, and building random ideas that I think could be useful, especially in the education space.$survey$, $survey$I want to build something I’m genuinely proud of and learn how to take an idea from a rough concept to a working product. I’d especially like to get better at using AI and data in a way that actually solves a real problem.$survey$, $survey$2026-09-11T15:38:07+00:00$survey$),
    ($survey$xf864$survey$, $survey$Xiangyue Fan$survey$, $survey$Junior$survey$, $survey$took_it$survey$, 3, 4, 2, 3, $survey$I work best in teams with clear roles, shared accountability, and balanced contributions. I like everyone to have ownership over a defined part of the project, rather than having one person carry most of the work or dominate all the decisions.$survey$, $survey$Photography, behavioral science, exploring new places in NYC, music$survey$, $survey$By December, I hope to have built an end-to-end project that is polished enough to include on my resume and portfolio. I also want to become better at pitching and communicating product ideas, while gaining more hands-on experience turning an idea into a working product—from prototyping and user feedback to implementation and deployment.$survey$, $survey$2026-09-11T15:51:58+00:00$survey$),
    ($survey$N16141501$survey$, $survey$Ali Shehadi$survey$, $survey$First-year$survey$, $survey$equivalent$survey$, 4, 3, 3, 4, $survey$I split work up based on what people are good at and discuss when there are questions or suggestions.$survey$, $survey$PC Building, Legos, Cars$survey$, $survey$I want to have an app that genuinely impresses people and I want to look really smart and like a hacker when I’m doing stuff on the terminal or something.$survey$, $survey$2026-09-11T17:55:44+00:00$survey$),
    ($survey$hmj8550$survey$, $survey$Hendry Jimenez Tejeda$survey$, $survey$Senior$survey$, $survey$took_it$survey$, 3, 2, 3, 4, $survey$I like being on top of things, so sort of creating a timeline of how I'm going to work on things.$survey$, $survey$Jewelry making, reading, crotchet, sewing$survey$, $survey$How to make an interactive app that connects people, I'd like to have built something that helps people i some way$survey$, $survey$2026-09-11T18:29:42+00:00$survey$),
    ($survey$muk2010$survey$, $survey$Sheharyar Khan$survey$, $survey$Junior$survey$, $survey$equivalent$survey$, 4, 4, 2, 4, $survey$Work consistently throughout the day rather than leaving everything for the end$survey$, $survey$Cricket!!
Swimming and golf$survey$, $survey$Something that people will use, that provides a purpose$survey$, $survey$2026-09-11T19:48:00+00:00$survey$),
    ($survey$sr7531$survey$, $survey$Olivia Rong$survey$, $survey$Senior$survey$, $survey$neither$survey$, 1, 4, 2, 5, $survey$I enjoy communicating with my teammates, and I’m usually quick to respond to messages. When I get down to work, I’m highly efficient and don’t like procrastination/time wasting.$survey$, $survey$Fishing, making coffee/drinking tea, reading$survey$, $survey$I hope I can master AI, learn how the python and frontend design work, and create an amazing app :)$survey$, $survey$2026-09-11T21:37:38+00:00$survey$),
    ($survey$ryf2010$survey$, $survey$Roxane Framroze$survey$, $survey$Sophomore$survey$, $survey$took_it$survey$, 3, 3, 3, 3, $survey$I am pretty spontaneous when it comes to ideas and tend to go with the flow for the most part. I also really get annoyed when people don't really take initiative because I have had bad experiences with such people in group projects.$survey$, $survey$Watching Formula 1; listening to music; trying new foods, restaurants, and cafes.$survey$, $survey$Although this is a class that encourages the use of AI, I still want to learn more about coding so I can have a better understanding about how apps actually work and understand more about their structure. I also want to build something that people would actually use in their day to day lives, even if it is not for a productive purpose.$survey$, $survey$2026-09-11T22:22:52+00:00$survey$),
    ($survey$ay2834$survey$, $survey$Allan You$survey$, $survey$Junior$survey$, $survey$equivalent$survey$, 3, 4, 2, 1, $survey$I work more efficiently in a group setting.$survey$, $survey$Side quests (walking, exploring the city), sports, public transportation, meeting new people$survey$, $survey$I want to build an app that would allow me to enjoy some of my hobbies more conveniently. In the long term, I would like to learn how to use AI to complement the skills I already have.$survey$, $survey$2026-09-11T22:30:01+00:00$survey$),
    ($survey$ax2128$survey$, $survey$Alex Xu$survey$, $survey$Senior$survey$, $survey$equivalent$survey$, 4, 5, 4, 5, $survey$In a collaborative setting, plan diligently, split the workload, and quickly finish a V1 so you have time to address issues and improvements.$survey$, $survey$Music, snowboarding, travel$survey$, $survey$I want to get to build something I personally will use, and get some more experience with using machine learning$survey$, $survey$2026-09-11T22:32:46+00:00$survey$),
    ($survey$ae3033$survey$, $survey$Adriana Escobedo$survey$, $survey$Sophomore$survey$, $survey$took_it$survey$, 2, 3, 1, 2, $survey$I feel like a work well with groups and I like to pace myself with certain checkpoints. I need to have deadlines to motivate progress.$survey$, $survey$I love everything music, jogging, and I am interested in marketing research as well. Love to make my own vlogs$survey$, $survey$I want to have built a well developed app that makes a true difference in the lives of others and would like to have foundational knowledge for future projects. I want to be able to learn all the implications about developing the app.$survey$, $survey$2026-09-11T23:29:25+00:00$survey$),
    ($survey$ra4292$survey$, $survey$Rania Aamer$survey$, $survey$Junior$survey$, $survey$took_it$survey$, 4, 2, 4, 4, $survey$I like working with others and dividing tasks clearly. I try to stay organized and communicate with my teammates throughout the project.$survey$, $survey$I enjoy playing chess, exploring new places, and spending time with friends. I’m also interested in technology and healthcare.$survey$, $survey$I want to build a project that is useful and actually works. I also want to become more confident with programming and data analysis.$survey$, $survey$2026-09-12T03:42:49+00:00$survey$),
    ($survey$mh7444$survey$, $survey$Muhammad Hamza$survey$, $survey$Junior$survey$, $survey$took_it$survey$, 4, 4, 3, 5, $survey$I like working in a team and making sure everyone has a clear role. I’m flexible with tasks and like helping out when needed.$survey$, $survey$I enjoy playing sports, hanging out with friends, and exploring new places. I also like learning about technology and different ideas.$survey$, $survey$I want to build something practical that I can be proud of by the end of the semester. I also want to improve my coding skills and learn how to work better with data.$survey$, $survey$2026-09-12T03:42:51+00:00$survey$),
    ($survey$ks7532$survey$, $survey$Kashish Satija$survey$, $survey$Junior$survey$, $survey$equivalent$survey$, 4, 3, 4, 3, $survey$I prefer working together and keeping things simple and organized. I like sharing ideas and making sure the work is divided fairly.$survey$, $survey$I like listening to music, watching movies, and spending time with friends. I also enjoy trying new things and learning new skills.$survey$, $survey$I want to build a project from scratch and learn more about how programming can be used to solve real problems. I also hope to get better at coding and teamwork$survey$, $survey$2026-09-12T03:44:12+00:00$survey$),
    ($survey$wg2481$survey$, $survey$Simon Gu$survey$, $survey$First-year$survey$, $survey$equivalent$survey$, 3, 4, 3, 4, $survey$I like to plan things out, discuss with others first, and then fix the PRD and then to work$survey$, $survey$movies, tennis, investing$survey$, $survey$Learn the feasibility of businesses, how to think of what to build, etc.$survey$, $survey$2026-09-12T03:53:52+00:00$survey$),
    ($survey$hj3146$survey$, $survey$Hajin Jung$survey$, $survey$Senior$survey$, $survey$neither$survey$, 1, 1, 4, 5, $survey$I’m generally flexible, hardworking, and respectful of my teammates’ time. I’m ready to put in the time and effort needed to contribute and get the job done well.$survey$, $survey$m interested in technology, especially finding creative ways to turn everyday problems into useful ideas that can have a real impact.$survey$, $survey$By December, I want to have built something that real users can interact with and benefit from. I also want to become more confident with coding, understand the product-development process from idea to execution, and learn how to build with a real user in mind.$survey$, $survey$2026-09-12T04:13:05+00:00$survey$),
    ($survey$ag9559$survey$, $survey$Dev Ganguli$survey$, $survey$Senior$survey$, $survey$took_it$survey$, 4, 4, 4, 4, $survey$Lots of planning and building a good foundation, taking on a leadership role, attention to detail$survey$, $survey$Real estate, tech, badminton$survey$, $survey$How to build a complex, fully functional app with a clear value proposition and marketing strategy$survey$, $survey$2026-09-12T18:22:33+00:00$survey$);

INSERT INTO student_tools (student_id, tool_id)
SELECT s.id, t.id
FROM (VALUES
    ($survey$jq2306$survey$, $survey$SQL$survey$),
    ($survey$jq2306$survey$, $survey$Python$survey$),
    ($survey$jq2306$survey$, $survey$Excel$survey$),
    ($survey$jq2306$survey$, $survey$JavaScript$survey$),
    ($survey$zh2740$survey$, $survey$Python$survey$),
    ($survey$zh2740$survey$, $survey$SQL$survey$),
    ($survey$zh2740$survey$, $survey$Excel$survey$),
    ($survey$yo2162$survey$, $survey$Python$survey$),
    ($survey$yo2162$survey$, $survey$SQL$survey$),
    ($survey$yo2162$survey$, $survey$JavaScript$survey$),
    ($survey$yo2162$survey$, $survey$R$survey$),
    ($survey$yo2162$survey$, $survey$Excel$survey$),
    ($survey$N16059079$survey$, $survey$Python$survey$),
    ($survey$N16059079$survey$, $survey$SQL$survey$),
    ($survey$N16059079$survey$, $survey$Excel$survey$),
    ($survey$N16059079$survey$, $survey$JavaScript$survey$),
    ($survey$nsc9331$survey$, $survey$Python$survey$),
    ($survey$nsc9331$survey$, $survey$Excel$survey$),
    ($survey$nsc9331$survey$, $survey$R$survey$),
    ($survey$nsc9331$survey$, $survey$SQL$survey$),
    ($survey$yk2772$survey$, $survey$SQL$survey$),
    ($survey$yk2772$survey$, $survey$Python$survey$),
    ($survey$yk2772$survey$, $survey$JavaScript$survey$),
    ($survey$yk2772$survey$, $survey$Excel$survey$),
    ($survey$ai2278$survey$, $survey$Excel$survey$),
    ($survey$ai2278$survey$, $survey$SQL$survey$),
    ($survey$ai2278$survey$, $survey$Python$survey$),
    ($survey$ai2278$survey$, $survey$JavaScript$survey$),
    ($survey$ai2278$survey$, $survey$R$survey$),
    ($survey$mr7316$survey$, $survey$Python$survey$),
    ($survey$mr7316$survey$, $survey$Excel$survey$),
    ($survey$mr7316$survey$, $survey$SQL$survey$),
    ($survey$xf864$survey$, $survey$Python$survey$),
    ($survey$xf864$survey$, $survey$R$survey$),
    ($survey$xf864$survey$, $survey$Excel$survey$),
    ($survey$N16141501$survey$, $survey$JavaScript$survey$),
    ($survey$N16141501$survey$, $survey$Excel$survey$),
    ($survey$N16141501$survey$, $survey$Python$survey$),
    ($survey$hmj8550$survey$, $survey$Python$survey$),
    ($survey$hmj8550$survey$, $survey$Excel$survey$),
    ($survey$hmj8550$survey$, $survey$SQL$survey$),
    ($survey$muk2010$survey$, $survey$Python$survey$),
    ($survey$muk2010$survey$, $survey$SQL$survey$),
    ($survey$muk2010$survey$, $survey$Excel$survey$),
    ($survey$sr7531$survey$, $survey$Excel$survey$),
    ($survey$ryf2010$survey$, $survey$Python$survey$),
    ($survey$ryf2010$survey$, $survey$SQL$survey$),
    ($survey$ryf2010$survey$, $survey$Excel$survey$),
    ($survey$ay2834$survey$, $survey$Python$survey$),
    ($survey$ay2834$survey$, $survey$SQL$survey$),
    ($survey$ay2834$survey$, $survey$Excel$survey$),
    ($survey$ax2128$survey$, $survey$Python$survey$),
    ($survey$ax2128$survey$, $survey$SQL$survey$),
    ($survey$ax2128$survey$, $survey$JavaScript$survey$),
    ($survey$ax2128$survey$, $survey$Excel$survey$),
    ($survey$ae3033$survey$, $survey$Python$survey$),
    ($survey$ae3033$survey$, $survey$SQL$survey$),
    ($survey$ae3033$survey$, $survey$Excel$survey$),
    ($survey$ra4292$survey$, $survey$Python$survey$),
    ($survey$ra4292$survey$, $survey$Excel$survey$),
    ($survey$ra4292$survey$, $survey$SQL$survey$),
    ($survey$mh7444$survey$, $survey$Python$survey$),
    ($survey$mh7444$survey$, $survey$Excel$survey$),
    ($survey$mh7444$survey$, $survey$SQL$survey$),
    ($survey$ks7532$survey$, $survey$Python$survey$),
    ($survey$ks7532$survey$, $survey$SQL$survey$),
    ($survey$ks7532$survey$, $survey$Excel$survey$),
    ($survey$ks7532$survey$, $survey$JavaScript$survey$),
    ($survey$wg2481$survey$, $survey$Python$survey$),
    ($survey$hj3146$survey$, $survey$Python$survey$),
    ($survey$hj3146$survey$, $survey$Excel$survey$),
    ($survey$ag9559$survey$, $survey$Excel$survey$),
    ($survey$ag9559$survey$, $survey$JavaScript$survey$),
    ($survey$ag9559$survey$, $survey$Python$survey$)
) AS listed (netid, tool_name)
JOIN students s ON s.netid = listed.netid
JOIN tools t ON t.name = listed.tool_name;

INSERT INTO student_availability (student_id, slot_id)
SELECT s.id, sl.id
FROM (VALUES
    ($survey$jq2306$survey$, $survey$Weekend mornings$survey$),
    ($survey$jq2306$survey$, $survey$Weekday mornings$survey$),
    ($survey$jq2306$survey$, $survey$Weekday evenings$survey$),
    ($survey$jq2306$survey$, $survey$Weekend afternoons$survey$),
    ($survey$zh2740$survey$, $survey$Weekend afternoons$survey$),
    ($survey$zh2740$survey$, $survey$Weekend evenings$survey$),
    ($survey$zh2740$survey$, $survey$Weekend mornings$survey$),
    ($survey$zh2740$survey$, $survey$Weekday mornings$survey$),
    ($survey$yo2162$survey$, $survey$Weekday mornings$survey$),
    ($survey$yo2162$survey$, $survey$Weekend mornings$survey$),
    ($survey$N16059079$survey$, $survey$Weekend mornings$survey$),
    ($survey$N16059079$survey$, $survey$Weekend afternoons$survey$),
    ($survey$N16059079$survey$, $survey$Weekend evenings$survey$),
    ($survey$N16059079$survey$, $survey$Weekday mornings$survey$),
    ($survey$nsc9331$survey$, $survey$Weekday evenings$survey$),
    ($survey$nsc9331$survey$, $survey$Weekend evenings$survey$),
    ($survey$nsc9331$survey$, $survey$Weekend afternoons$survey$),
    ($survey$nsc9331$survey$, $survey$Weekend mornings$survey$),
    ($survey$yk2772$survey$, $survey$Weekday evenings$survey$),
    ($survey$yk2772$survey$, $survey$Weekday afternoons$survey$),
    ($survey$ai2278$survey$, $survey$Weekday mornings$survey$),
    ($survey$ai2278$survey$, $survey$Weekend mornings$survey$),
    ($survey$ai2278$survey$, $survey$Weekend afternoons$survey$),
    ($survey$ai2278$survey$, $survey$Weekday afternoons$survey$),
    ($survey$ai2278$survey$, $survey$Weekday evenings$survey$),
    ($survey$ai2278$survey$, $survey$Weekend evenings$survey$),
    ($survey$mr7316$survey$, $survey$Weekday mornings$survey$),
    ($survey$mr7316$survey$, $survey$Weekday afternoons$survey$),
    ($survey$mr7316$survey$, $survey$Weekday evenings$survey$),
    ($survey$mr7316$survey$, $survey$Weekend mornings$survey$),
    ($survey$mr7316$survey$, $survey$Weekend afternoons$survey$),
    ($survey$mr7316$survey$, $survey$Weekend evenings$survey$),
    ($survey$xf864$survey$, $survey$Weekday mornings$survey$),
    ($survey$xf864$survey$, $survey$Weekday afternoons$survey$),
    ($survey$xf864$survey$, $survey$Weekend afternoons$survey$),
    ($survey$xf864$survey$, $survey$Weekend evenings$survey$),
    ($survey$N16141501$survey$, $survey$Weekday mornings$survey$),
    ($survey$N16141501$survey$, $survey$Weekday evenings$survey$),
    ($survey$N16141501$survey$, $survey$Weekday afternoons$survey$),
    ($survey$hmj8550$survey$, $survey$Weekday mornings$survey$),
    ($survey$hmj8550$survey$, $survey$Weekday afternoons$survey$),
    ($survey$hmj8550$survey$, $survey$Weekend afternoons$survey$),
    ($survey$hmj8550$survey$, $survey$Weekday evenings$survey$),
    ($survey$muk2010$survey$, $survey$Weekday mornings$survey$),
    ($survey$sr7531$survey$, $survey$Weekend mornings$survey$),
    ($survey$sr7531$survey$, $survey$Weekend afternoons$survey$),
    ($survey$sr7531$survey$, $survey$Weekend evenings$survey$),
    ($survey$ryf2010$survey$, $survey$Weekend afternoons$survey$),
    ($survey$ryf2010$survey$, $survey$Weekend mornings$survey$),
    ($survey$ay2834$survey$, $survey$Weekday evenings$survey$),
    ($survey$ay2834$survey$, $survey$Weekday afternoons$survey$),
    ($survey$ay2834$survey$, $survey$Weekend afternoons$survey$),
    ($survey$ay2834$survey$, $survey$Weekend evenings$survey$),
    ($survey$ax2128$survey$, $survey$Weekday evenings$survey$),
    ($survey$ax2128$survey$, $survey$Weekend afternoons$survey$),
    ($survey$ax2128$survey$, $survey$Weekday mornings$survey$),
    ($survey$ae3033$survey$, $survey$Weekday afternoons$survey$),
    ($survey$ae3033$survey$, $survey$Weekday evenings$survey$),
    ($survey$ae3033$survey$, $survey$Weekend afternoons$survey$),
    ($survey$ae3033$survey$, $survey$Weekend evenings$survey$),
    ($survey$ae3033$survey$, $survey$Weekend mornings$survey$),
    ($survey$ra4292$survey$, $survey$Weekday mornings$survey$),
    ($survey$ra4292$survey$, $survey$Weekend afternoons$survey$),
    ($survey$mh7444$survey$, $survey$Weekday mornings$survey$),
    ($survey$mh7444$survey$, $survey$Weekend afternoons$survey$),
    ($survey$ks7532$survey$, $survey$Weekday mornings$survey$),
    ($survey$ks7532$survey$, $survey$Weekend afternoons$survey$),
    ($survey$wg2481$survey$, $survey$Weekday afternoons$survey$),
    ($survey$hj3146$survey$, $survey$Weekend afternoons$survey$),
    ($survey$hj3146$survey$, $survey$Weekday afternoons$survey$),
    ($survey$ag9559$survey$, $survey$Weekday evenings$survey$),
    ($survey$ag9559$survey$, $survey$Weekend evenings$survey$),
    ($survey$ag9559$survey$, $survey$Weekend afternoons$survey$)
) AS listed (netid, slot_label)
JOIN students s ON s.netid = listed.netid
JOIN availability_slots sl ON sl.label = listed.slot_label;

COMMIT;
